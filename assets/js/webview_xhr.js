let flutter__xhr__open = XMLHttpRequest.prototype.open;
let flutter__xhr__send = XMLHttpRequest.prototype.send;
XMLHttpRequest.prototype.open = function () {
	let [method, url, async, user, pass] = arguments;

	this.flutter__url = url;
	this.flutter__real = typeof async === "boolean" && url.startsWith("http");

	return flutter__xhr__open.call(this, ...arguments);
};

XMLHttpRequest.prototype.send = function () {
	if (this.flutter__real) {
		flutter__sendMessageToFlutter('start', this.flutter__url);
	}
	this.addEventListener('readystatechange', () => {
		if (this.readyState === 4 && this.flutter__real) {
			flutter__sendMessageToFlutter('end', this.flutter__url);
		}
	});

	return flutter__xhr__send.call(this, ...arguments);
};
