async function createLLMResponse(message) {
    try {
        const response = await fetch("/getLLMResponse", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message: message }),
        });
        
        console.log(response);

        const data = await response.json();

        if (data.response) {
            console.log("Response:", data.response);
        } else {
            console.error("Error:", data.error || "Unknown error");
        }
    } catch (err) {
        console.error("Fetch error:", err);
    }
}

createLLMResponse("hi");

const usrMsgBox = document.getElementById('msgtobot')
if (usrMsgBox) {
    
}