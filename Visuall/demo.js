// demo.js

var __bridge;
var counter = 0;

function increaseCounter (num) {
    if (num == null)
    {
        num = -999;
    }
    counter = counter + num;
    document.getElementById('myId').value = counter;
    
    if (__bridge) {
    __bridge.callHandler('ObjC Echo', {'key': counter}, function responseCallback(responseData) {
                       console.log("JS received response:", responseData)
                       });
    }
}

function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}


window.onload = function() {
    increaseCounter(0);
    
    setupWebViewJavascriptBridge(function(bridge) {
                                 
                                 /* Initialize your app here */
                                 __bridge = bridge;
                                 
                                 bridge.registerHandler('JS Echo', function(data, responseCallback) {
                                                        console.log("JS Echo called with:", data)
                                                        data["myKey"] = 17;
                                                        responseCallback(data)
                                                        });
                                 
                                 bridge.callHandler('ObjC Echo', {'key':'value'}, function responseCallback(responseData) {
                                                    console.log("JS received response:", responseData)
                                                    });
                                 })
}
