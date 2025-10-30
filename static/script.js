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
        
        botClone.querySelector('div').querySelector('img').src = "/static/AItherapist.png"
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

const container = document.getElementById("container");
const particleCount = 10;
const edges = ['top', 'right', 'bottom', 'left'];

function getRandomEdgePosition(edge) {
    switch (edge) {
        case 'top':
        return { x: Math.random() * 100 + 'vw', y: '-10vh' }; // just above viewport
        case 'right':
        return { x: '110vw', y: Math.random() * 100 + 'vh' }; // just right of viewport
        case 'bottom':
        return { x: Math.random() * 100 + 'vw', y: '110vh' }; // just below viewport
        case 'left':
        return { x: '-10vw', y: Math.random() * 100 + 'vh' }; // just left of viewport
    }
}
for (let i = 0; i < particleCount; i++) {
    const particle = document.createElement('div');
    particle.classList.add('particle');

    // Random size
    particle.classList.add(Math.random() > 0.5 ? 'large' : 'small');

    // Pick random start edge
    let startEdge = edges[Math.floor(Math.random() * edges.length)];
    
    // Pick random end edge, different from start
    let endEdge;
    do {
        endEdge = edges[Math.floor(Math.random() * edges.length)];
    } while (endEdge === startEdge);

    // Get start and end positions offscreen
    const startPos = getRandomEdgePosition(startEdge);
    const endPos = getRandomEdgePosition(endEdge);

    // Set CSS variables
    particle.style.setProperty('--start-x', startPos.x);
    particle.style.setProperty('--start-y', startPos.y);
    particle.style.setProperty('--start-z', Math.floor(Math.random() * 100) + 'px');

    particle.style.setProperty('--end-x', endPos.x);
    particle.style.setProperty('--end-y', endPos.y);
    particle.style.setProperty('--end-z', Math.floor(Math.random() * 100) + 'px');

    particle.style.setProperty('--rotation', Math.floor(Math.random() * 1080) + 'deg');
    particle.style.setProperty('--delay', `-${(Math.random()).toFixed(2)}s`);

    container.appendChild(particle);
}
