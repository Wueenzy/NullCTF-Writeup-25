use "net"
use "files"
use "jennet"
use "http_server"
use "collections"



actor Main
  new create(env: Env) =>
    let tcplauth: TCPListenAuth = TCPListenAuth(env.root)
    let fileauth: FileAuth = FileAuth(env.root)

    let server =
      Jennet(tcplauth, env.out)
        .> serve_file(fileauth, "/", "public/index.html")
        .> serve_file(fileauth, "/pony", "public/pony.html")
        .> post("/pony/find", PonyFind(fileauth))
        .> get("/flag", F(fileauth))
        .> get("/:name", H(fileauth))
        .serve(ServerConfig(
          where host' = "0.0.0.0",
                port' = "8081",
                max_concurrent_connections' = 10000
        ))

    if server is None then
      env.out.print("bad routes!")
    end



class F is RequestHandler
  let _fileauth: FileAuth
  
  new val create(fileauth: FileAuth) =>
    _fileauth = fileauth

  fun apply(ctx: Context): Context iso^ =>
    var conn: String = ""
    var body = "[REDACTED]".array()
    
    try
      conn = ctx.request.header("Host") as String
    end
    
    let path: String = ctx.request.uri().string()

    if (conn == "127.0.0.1") and (path != "/flag") and (path != "flag") then
      let fpath = FilePath(_fileauth, "public/flag.html")
      with file = File(fpath) do
        body = file.read_string(file.size()).string().array()
      end
    end

    ctx.respond(
      StatusResponse(StatusOK, [("Content-Length", body.size().string())]),
      body
    )
    consume ctx



class H is RequestHandler
  let _fileauth: FileAuth
  
  new val create(fileauth: FileAuth) =>
    _fileauth = fileauth

  fun apply(ctx: Context): Context iso^ =>
    try
      let name = URLEncode.decode(ctx.param("name"))?
      let body = "".join(
        [ "Not found"; if name != "" then " " + name else "" end; "!"
        ].values()).array()
      ctx.respond(
        StatusResponse(StatusOK, [("Content-Length", body.size().string())]),
        body
      )
    else
      let body = "Error".array()
      ctx.respond(
        StatusResponse(StatusOK, [("Content-Length", body.size().string())]),
        body
      )
    end
    consume ctx



class PonyFind is RequestHandler
  let _fileauth: FileAuth
  
  new val create(fileauth: FileAuth) =>
    _fileauth = fileauth

  fun apply(ctx: Context): Context iso^ =>
    let body' = ctx.body
    let form_data = recover val FormData.parse(body'.string()) end
    
    var html: String = ""
    if form_data.is_valid() then
      let path = FilePath(_fileauth, "public/report.html")
      with file = File(path) do
        var content: String ref = file.read_string(file.size()).string()
        form_data._inject_form_data(content)
        html = content.string()
      end
    else
      let path = FilePath(_fileauth, "public/error.html")
      with file = File(path) do
        html = file.read_string(file.size()).string()
      end
    end

    let html_arr = html.array()
    ctx.respond(
      StatusResponse(StatusOK, [("Content-Length", html_arr.size().string())]),
      html_arr
    )
    consume ctx



class FormData
  let data: Map[String, String] = Map[String, String]
  
  new val parse(body: String) =>
    for pair in body.split_by("&").values() do
      let kv = pair.split_by("=")
      if kv.size() == 2 then
        try
          data(kv(0)?) = kv(1)?
        end
      end
    end
  
  fun is_valid(): Bool =>
    data.contains("reporterName") and
    data.contains("sightingLocation") and
    data.contains("contactMethod") and
    data.contains("message")
  
  fun get_or_else(key: String, default: String = ""): String =>
    try data(key)? else default end
  
  fun apply(key: String): String =>
    try data(key)? else "" end

  fun extract_template_vars(s: String ref): Array[String] ref^ =>
    let vars: Array[String] ref = recover Array[String] end
    var pos: ISize = 0
    
    try
      let len = s.size().isize()

      while pos < len do
        let start = s.find("{{", pos)?
        let end_pos = s.find("}}", start + 2)?

        var var_name = s.substring(start + 2, end_pos).clone()
        if var_name isnt None then
          var_name.strip()
          if var_name.size() > 0 then
            vars.push(consume var_name)
          end
        end
        
        pos = end_pos + 2
      end
    end
    
    consume vars

  fun _inject_form_data(html: String ref) =>
    let vars = extract_template_vars(html)
    for name in vars.values() do
      if data.contains(name) then
        html.replace("{{" + name + "}}", try data(name)? else "{{" + name + "}}" end)
      end
    end
