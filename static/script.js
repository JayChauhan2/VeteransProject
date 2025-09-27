async function createLLMResponse(message) {
    try {
        const response = await fetch("/getLLMResponse", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message: message }),
        });
        
        const data = await response.json();

        if (data.response) {
            return data.response;
        } else {
            return data.error;
        }
    } catch (err) {
        return err;
    }
}

const usrMsgHolder = document.getElementById('usr-msg-holder')
if (usrMsgHolder) {
    const usrMsgBox = usrMsgHolder.querySelector('textarea')
    const usrMsgSend = usrMsgHolder.querySelector('button')
    const msgTemplate = document.getElementById('msg')
    const msgZone = document.getElementById('msg-zone')
    usrMsgSend.addEventListener("click", async function() {
        let usrMsg = usrMsgBox.value.trim()
        if (!(usrMsg.length > 0)) return;
        
        const userClone = msgTemplate.content.cloneNode(true)
        const userCloneDiv = userClone.querySelector('div')
        userCloneDiv.classList.add('user')
        userCloneDiv.querySelector('div').innerText = usrMsg
        usrMsgBox.value = "";
        msgZone.appendChild(userClone)

        const botClone = msgTemplate.content.cloneNode(true)
        botClone.querySelector('div').querySelector('div').innerText = await createLLMResponse(usrMsg)
        msgZone.appendChild(botClone)
    
    })
}

const calendarAdd = document.getElementsByClassName('calendar-add')[0]
if (calendarAdd) {
    calendarAdd.onclick = function () {
        const clone = document.getElementById('createEventBundle').content.cloneNode(true)
        document.getElementsByTagName('main')[0].appendChild(clone)
    }
}