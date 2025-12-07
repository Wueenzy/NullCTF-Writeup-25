function postRequest(path, data) {
    const token = localStorage.getItem("token");
    return fetch(`${CONSTANTS.href}${path}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            ...(token ? {
                Authorization: `Bearer ${token}`,
            } : {})
        },
        body: JSON.stringify(data),
    });
}
