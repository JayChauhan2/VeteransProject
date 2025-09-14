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

const calendarAdd = document.getElementsByClassName('calendar-add')[0]
if (calendarAdd) {
    calendarAdd.onclick = function () {
        const clone = document.getElementById('createEventBundle').content.cloneNode(true);
        document.getElementsByTagName('main')[0].appendChild(clone);
    }
}