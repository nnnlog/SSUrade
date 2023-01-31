window.flutter__sendMessageToFlutter = function () {
    return new Promise(r => {
        let id = setInterval(() => {
            if (window.flutter_inappwebview.callHandler !== undefined) {
                clearInterval(id);

                window.flutter_inappwebview.callHandler(...arguments);
                r();
            }
        }, 1);
    });
};

if (document.readyState === "complete") {
    flutter__sendMessageToFlutter("load");
} else {
    window.addEventListener('load', () => {
        flutter__sendMessageToFlutter("load");
    });
}
