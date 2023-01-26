window.flutter__open__real = window.open;
window.flutter__open__callback = function () {
	return flutter__sendMessageToFlutter("redirect", arguments[0] ?? "");
};
window.open = function () {
	window.flutter__open__callback(...arguments);
};
