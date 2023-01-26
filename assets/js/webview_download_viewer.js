window.URL.createObjectURL = function(obj) {
	flutter__sendMessageToFlutter("debug", JSON.stringify(arguments));
    if (obj instanceof Blob) {
        obj.arrayBuffer().then(a => {
            let dec = new TextDecoder("utf-16le", {
                ignoreBOM: true,
                fatal: false,
            });
            flutter__sendMessageToFlutter("download", dec.decode(a));
        });
        throw new Error(); // prevent download
    } else {
        throw new Error(); // unknown
    }
};
