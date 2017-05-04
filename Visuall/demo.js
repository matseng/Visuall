// demo.js

var counter = 0;

function increaseCounter (num) {
    if (num == null)
    {
        num = -999;
    }
    counter = counter + num;
    document.getElementById('myId').value = counter;
}


window.onload = function() {
    increaseCounter(0);
}
