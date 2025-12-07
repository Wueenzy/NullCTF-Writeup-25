use ftp::FtpStream;
use std::env;

pub struct FtpWrapper {
    pub stream: FtpStream,
}

impl Drop for FtpWrapper {
    fn drop(&mut self) {
        self.stream.quit().ok();
    }
}


pub fn get_ftp() -> FtpWrapper {
    let mut ftp = FtpStream::connect(
        format!("{}:{}", env::var("FTP_HOST").unwrap(), env::var("FTP_PORT").unwrap())
    ).unwrap();
    ftp.login(&env::var("FTP_USER").unwrap(), &env::var("FTP_PASS").unwrap()).unwrap();

    FtpWrapper {
        stream: ftp,
    }
}