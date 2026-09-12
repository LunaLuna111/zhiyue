part of '../../pages/web_page.dart';

@visibleForTesting
String buildPrivacyWebFingerprintScript() =>
    '''
(() => {
  if (window.__zhiyuePrivacyProfileInstalled) return;
  Object.defineProperty(window, '__zhiyuePrivacyProfileInstalled', {
    value: true,
    configurable: false,
    enumerable: false,
  });

  const safeGetter = (target, name, getter) => {
    try {
      Object.defineProperty(target, name, {
        get: getter,
        configurable: true,
        enumerable: true,
      });
    } catch (_) {}
  };
  const safeValue = (target, name, value) => {
    try {
      Object.defineProperty(target, name, {
        value,
        configurable: true,
        writable: true,
      });
    } catch (_) {}
  };

  const navigatorPrototype = Object.getPrototypeOf(navigator);
  safeGetter(navigatorPrototype, 'userAgent', () => '${PrivacyDeviceProfile.appUserAgent}');
  safeGetter(navigatorPrototype, 'appVersion', () => '${PrivacyDeviceProfile.appUserAgent.substring(PrivacyDeviceProfile.appUserAgent.indexOf('Mozilla/5.0'))}');
  safeGetter(navigatorPrototype, 'platform', () => 'Linux armv8l');
  safeGetter(navigatorPrototype, 'vendor', () => 'Google Inc.');
  safeGetter(navigatorPrototype, 'language', () => '${PrivacyDeviceProfile.language}');
  safeGetter(navigatorPrototype, 'languages', () => Object.freeze(['zh-CN', 'zh']));
  safeGetter(navigatorPrototype, 'hardwareConcurrency', () => ${PrivacyDeviceProfile.cpuCores});
  safeGetter(navigatorPrototype, 'deviceMemory', () => ${PrivacyDeviceProfile.browserDeviceMemoryGiB});
  safeGetter(navigatorPrototype, 'maxTouchPoints', () => ${PrivacyDeviceProfile.maxTouchPoints});
  safeGetter(navigatorPrototype, 'webdriver', () => false);

  const uaData = Object.freeze({
    brands: Object.freeze([
      Object.freeze({brand: 'Chromium', version: '57'}),
      Object.freeze({brand: 'Not/A)Brand', version: '8'}),
    ]),
    mobile: true,
    platform: 'Android',
    getHighEntropyValues: async (hints) => {
      const values = {
        architecture: 'arm',
        bitness: '64',
        formFactors: Object.freeze(['Mobile']),
        fullVersionList: Object.freeze([
          Object.freeze({brand: 'Chromium', version: '57.0.1000.10'}),
          Object.freeze({brand: 'Not/A)Brand', version: '8.0.0.0'}),
        ]),
        model: '${PrivacyDeviceProfile.model}',
        platformVersion: '${PrivacyDeviceProfile.androidRelease}.0.0',
        uaFullVersion: '57.0.1000.10',
        wow64: false,
      };
      const result = {brands: uaData.brands, mobile: true, platform: 'Android'};
      for (const hint of hints || []) {
        if (Object.prototype.hasOwnProperty.call(values, hint)) {
          result[hint] = values[hint];
        }
      }
      return result;
    },
    toJSON: () => ({brands: uaData.brands, mobile: true, platform: 'Android'}),
  });
  safeGetter(navigatorPrototype, 'userAgentData', () => uaData);

  if (typeof Screen !== 'undefined') {
    safeGetter(Screen.prototype, 'width', () => ${PrivacyDeviceProfile.logicalScreenWidth});
    safeGetter(Screen.prototype, 'height', () => ${PrivacyDeviceProfile.logicalScreenHeight});
    safeGetter(Screen.prototype, 'availWidth', () => ${PrivacyDeviceProfile.logicalScreenWidth});
    safeGetter(Screen.prototype, 'availHeight', () => ${PrivacyDeviceProfile.availableScreenHeight});
    safeGetter(Screen.prototype, 'colorDepth', () => 24);
    safeGetter(Screen.prototype, 'pixelDepth', () => 24);
  }
  safeGetter(window, 'devicePixelRatio', () => ${PrivacyDeviceProfile.devicePixelRatio});
  if (typeof ScreenOrientation !== 'undefined') {
    safeGetter(ScreenOrientation.prototype, 'type', () => 'portrait-primary');
    safeGetter(ScreenOrientation.prototype, 'angle', () => 0);
  }

  const dateShiftMillis = ${PrivacyDeviceProfile.timezoneOffsetSeconds} * 1000;
  const privacyTimeZone = '${PrivacyDeviceProfile.timeZoneName}';
  const privacyLocale = '${PrivacyDeviceProfile.language}';
  safeValue(Date.prototype, 'getTimezoneOffset', function() { return -480; });
  const shiftedDate = (date) => new Date(date.getTime() + dateShiftMillis);
  const localDateGetters = {
    getFullYear: 'getUTCFullYear',
    getMonth: 'getUTCMonth',
    getDate: 'getUTCDate',
    getDay: 'getUTCDay',
    getHours: 'getUTCHours',
    getMinutes: 'getUTCMinutes',
    getSeconds: 'getUTCSeconds',
    getMilliseconds: 'getUTCMilliseconds',
  };
  for (const [localName, utcName] of Object.entries(localDateGetters)) {
    safeValue(Date.prototype, localName, function() {
      return shiftedDate(this)[utcName]();
    });
  }
  const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const pad2 = (value) => String(value).padStart(2, '0');
  const privacyDateParts = (date) => {
    const shifted = shiftedDate(date);
    return {
      weekDay: weekDays[shifted.getUTCDay()],
      month: months[shifted.getUTCMonth()],
      day: pad2(shifted.getUTCDate()),
      year: shifted.getUTCFullYear(),
      time: pad2(shifted.getUTCHours()) + ':' +
        pad2(shifted.getUTCMinutes()) + ':' + pad2(shifted.getUTCSeconds()),
    };
  };
  safeValue(Date.prototype, 'toDateString', function() {
    const value = privacyDateParts(this);
    return value.weekDay + ' ' + value.month + ' ' + value.day + ' ' + value.year;
  });
  safeValue(Date.prototype, 'toTimeString', function() {
    return privacyDateParts(this).time + ' GMT+0800 (China Standard Time)';
  });
  safeValue(Date.prototype, 'toString', function() {
    return this.toDateString() + ' ' + this.toTimeString();
  });
  if (typeof Intl !== 'undefined' && Intl.DateTimeFormat) {
    const NativeDateTimeFormat = Intl.DateTimeFormat;
    const originalResolvedOptions = NativeDateTimeFormat.prototype.resolvedOptions;
    const fixedDateTimeOptions = (options) => {
      const normalized = {...(options || {})};
      if (!normalized.timeZone) normalized.timeZone = privacyTimeZone;
      return normalized;
    };
    const PrivacyDateTimeFormat = function(locales, options) {
      return new NativeDateTimeFormat(locales || privacyLocale, fixedDateTimeOptions(options));
    };
    PrivacyDateTimeFormat.prototype = NativeDateTimeFormat.prototype;
    Object.setPrototypeOf(PrivacyDateTimeFormat, NativeDateTimeFormat);
    safeValue(PrivacyDateTimeFormat, 'supportedLocalesOf',
      NativeDateTimeFormat.supportedLocalesOf.bind(NativeDateTimeFormat));
    safeValue(Intl.DateTimeFormat.prototype, 'resolvedOptions', function() {
      const options = originalResolvedOptions.call(this);
      return {...options, locale: privacyLocale, timeZone: privacyTimeZone};
    });
    safeValue(Intl, 'DateTimeFormat', PrivacyDateTimeFormat);

    const localeMethods = ['toLocaleString', 'toLocaleDateString', 'toLocaleTimeString'];
    for (const methodName of localeMethods) {
      const originalMethod = Date.prototype[methodName];
      safeValue(Date.prototype, methodName, function(locales, options) {
        return originalMethod.call(
          this,
          locales || privacyLocale,
          fixedDateTimeOptions(options),
        );
      });
    }
  }

  const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
  if (connection) {
    const connectionPrototype = Object.getPrototypeOf(connection);
    safeGetter(connectionPrototype, 'type', () => 'wifi');
    safeGetter(connectionPrototype, 'effectiveType', () => '4g');
    safeGetter(connectionPrototype, 'downlink', () => 10);
    safeGetter(connectionPrototype, 'rtt', () => 50);
    safeGetter(connectionPrototype, 'saveData', () => false);
  }
  safeValue(navigatorPrototype, 'getBattery', () => Promise.resolve({
    charging: true,
    chargingTime: 0,
    dischargingTime: Infinity,
    level: 0.76,
    addEventListener: () => {},
    removeEventListener: () => {},
  }));

  const patchWebGl = (prototype) => {
    if (!prototype) return;
    const originalGetParameter = prototype.getParameter;
    const originalGetExtension = prototype.getExtension;
    if (originalGetParameter) {
      safeValue(prototype, 'getParameter', function(parameter) {
        if (parameter === 37445) return '${PrivacyDeviceProfile.webGlVendor}';
        if (parameter === 37446) return '${PrivacyDeviceProfile.webGlRenderer}';
        return originalGetParameter.call(this, parameter);
      });
    }
    if (originalGetExtension) {
      safeValue(prototype, 'getExtension', function(name) {
        if (String(name).toLowerCase() === 'webgl_debug_renderer_info') {
          return Object.freeze({UNMASKED_VENDOR_WEBGL: 37445, UNMASKED_RENDERER_WEBGL: 37446});
        }
        return originalGetExtension.call(this, name);
      });
    }
  };
  patchWebGl(typeof WebGLRenderingContext === 'undefined' ? null : WebGLRenderingContext.prototype);
  patchWebGl(typeof WebGL2RenderingContext === 'undefined' ? null : WebGL2RenderingContext.prototype);

  // Normalize canvas readback so small GPU/font rasterizer differences do not
  // become a stable copy of the host device. The visible canvas is untouched.
  const normalizeCanvasPixels = (imageData) => {
    const pixels = imageData && imageData.data;
    if (!pixels) return imageData;
    for (let index = 0; index < pixels.length; index += 4) {
      pixels[index] = pixels[index] & 0xfc;
      pixels[index + 1] = pixels[index + 1] & 0xfc;
      pixels[index + 2] = pixels[index + 2] & 0xfc;
    }
    return imageData;
  };
  if (typeof CanvasRenderingContext2D !== 'undefined') {
    const canvas2d = CanvasRenderingContext2D.prototype;
    const originalGetImageData = canvas2d.getImageData;
    const originalPutImageData = canvas2d.putImageData;
    if (originalGetImageData) {
      safeValue(canvas2d, 'getImageData', function(...args) {
        return normalizeCanvasPixels(originalGetImageData.apply(this, args));
      });
    }
    if (typeof HTMLCanvasElement !== 'undefined') {
      const canvasElement = HTMLCanvasElement.prototype;
      const originalToDataURL = canvasElement.toDataURL;
      const originalToBlob = canvasElement.toBlob;
      const normalizedCanvas = (source) => {
        try {
          if (!source.width || !source.height) return source;
          const copy = document.createElement('canvas');
          copy.width = source.width;
          copy.height = source.height;
          const context = copy.getContext('2d');
          if (!context || !originalGetImageData || !originalPutImageData) return source;
          context.drawImage(source, 0, 0);
          const pixels = originalGetImageData.call(context, 0, 0, copy.width, copy.height);
          originalPutImageData.call(context, normalizeCanvasPixels(pixels), 0, 0);
          return copy;
        } catch (_) {
          return source;
        }
      };
      if (originalToDataURL) {
        safeValue(canvasElement, 'toDataURL', function(...args) {
          return originalToDataURL.apply(normalizedCanvas(this), args);
        });
      }
      if (originalToBlob) {
        safeValue(canvasElement, 'toBlob', function(...args) {
          return originalToBlob.apply(normalizedCanvas(this), args);
        });
      }
    }
  }

  const patchAudioContext = (contextType) => {
    if (!contextType || !contextType.prototype) return;
    safeGetter(contextType.prototype, 'sampleRate', () => 48000);
    safeGetter(contextType.prototype, 'baseLatency', () => 0.01);
    safeGetter(contextType.prototype, 'outputLatency', () => 0.04);
  };
  patchAudioContext(typeof AudioContext === 'undefined' ? null : AudioContext);
  patchAudioContext(typeof OfflineAudioContext === 'undefined' ? null : OfflineAudioContext);
  if (typeof AudioBuffer !== 'undefined') {
    safeGetter(AudioBuffer.prototype, 'sampleRate', () => 48000);
  }
  if (typeof AnalyserNode !== 'undefined') {
    const analyser = AnalyserNode.prototype;
    for (const methodName of ['getFloatFrequencyData', 'getFloatTimeDomainData']) {
      const originalMethod = analyser[methodName];
      if (!originalMethod) continue;
      safeValue(analyser, methodName, function(values) {
        originalMethod.call(this, values);
        for (let index = 0; index < values.length; index++) {
          values[index] = Math.round(values[index] * 10000) / 10000;
        }
      });
    }
  }
})();
''';
