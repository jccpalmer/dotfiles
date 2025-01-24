/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./src/contentScripts/markdownIt.ts":
/*!******************************************!*\
  !*** ./src/contentScripts/markdownIt.ts ***!
  \******************************************/
/***/ ((__unused_webpack_module, exports, __webpack_require__) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nconst localization_1 = __webpack_require__(/*! ../localization */ \"./src/localization.ts\");\n// We need to pass [editSvgCommandIdentifier] as an argument because we're converting\n// editImage to a string.\nconst editImage = (contentScriptId, container, svgId) => {\n    var _a;\n    // Don't declare as a toplevel constant -- editImage is stringified.\n    const debug = false;\n    const imageElem = (_a = container.querySelector('img')) !== null && _a !== void 0 ? _a : document.querySelector(`img#${svgId}`);\n    if (!(imageElem === null || imageElem === void 0 ? void 0 : imageElem.src)) {\n        throw new Error(`${imageElem} lacks an src attribute. Unable to edit!`);\n    }\n    const updateCachebreaker = (initialSrc) => {\n        var _a;\n        var _b;\n        // Strip the ?t=... at the end of the image URL\n        const cachebreakerMatch = /^(.*)\\?t=(\\d+)$/.exec(initialSrc);\n        const fileUrl = cachebreakerMatch ? cachebreakerMatch[1] : initialSrc;\n        const oldCachebreaker = cachebreakerMatch ? parseInt(cachebreakerMatch[2]) : 0;\n        const newCachebreaker = new Date().getTime();\n        // Add the cachebreaker to the global list -- we may need to change cachebreakers\n        // on future rerenders.\n        (_a = (_b = window)['outOfDateCacheBreakers']) !== null && _a !== void 0 ? _a : (_b['outOfDateCacheBreakers'] = {});\n        window['outOfDateCacheBreakers'][fileUrl] = {\n            outdated: oldCachebreaker,\n            suggested: newCachebreaker,\n        };\n        return `${fileUrl}?t=${newCachebreaker}`;\n    };\n    // The webview api is different if we're running in the TinyMce editor vs if we're running\n    // in the preview pane.\n    const message = imageElem.src;\n    const imageElemClass = `imageelem-${new Date().getTime()}`;\n    imageElem.classList.add(imageElemClass);\n    try {\n        let postMessage;\n        try {\n            postMessage = webviewApi.postMessage;\n        }\n        catch (error) {\n            // Don't log by default\n            if (debug) {\n                console.error('Unable to access webviewApi.postMessage: ', error);\n            }\n        }\n        if (!postMessage) {\n            // TODO:\n            //  This is a hack to work around the lack of a webviewApi in the rich text editor\n            //  webview.\n            //  As top.require **should not work** at some point in the future, this will fail.\n            const PluginService = top.require('@joplin/lib/services/plugins/PluginService').default;\n            postMessage = (contentScriptId, message) => {\n                const pluginService = PluginService.instance();\n                const pluginId = pluginService.pluginIdByContentScriptId(contentScriptId);\n                return pluginService\n                    .pluginById(pluginId)\n                    .emitContentScriptMessage(contentScriptId, message);\n            };\n        }\n        postMessage(contentScriptId, message)\n            .then((resourceId) => {\n            // Update all matching\n            const toRefresh = document.querySelectorAll(`\n\t\t\t\t\timg[data-resource-id=\"${resourceId}\"],\n\t\t\t\t\timg[data-mce-src*=\"/${resourceId}.svg\"]\n\t\t\t\t`);\n            for (const elem of toRefresh) {\n                const imageElem = elem;\n                imageElem.src = updateCachebreaker(imageElem.src);\n            }\n        })\n            .catch((err) => {\n            console.error('Error posting message!', err, '\\nMessage: ', message);\n        });\n    }\n    catch (err) {\n        console.warn('Error posting message', err);\n    }\n};\nconst onImgLoad = (container, buttonId) => {\n    var _a, _b, _c, _d;\n    let button = container.querySelector('button.jsdraw--editButton');\n    const imageElem = container.querySelector('img');\n    if (!imageElem) {\n        throw new Error('js-draw editor: Unable to find an image in the given container!');\n    }\n    // Another plugin may have moved the button\n    if (!button) {\n        button = document.querySelector(`#${buttonId}`);\n        // In the rich text editor, an image might be reloading when the button has already\n        // been removed:\n        if (!button) {\n            return;\n        }\n        button.remove();\n        container.appendChild(button);\n    }\n    container.classList.add('jsdraw--svgWrapper');\n    const outOfDateCacheBreakers = (_a = window['outOfDateCacheBreakers']) !== null && _a !== void 0 ? _a : {};\n    const imageSrcMatch = /^(.*)\\?t=(\\d+)$/.exec(imageElem.src);\n    if (!imageSrcMatch) {\n        throw new Error(`${imageElem === null || imageElem === void 0 ? void 0 : imageElem.src} doesn't have a cachebreaker! Unable to update it.`);\n    }\n    const fileUrl = imageSrcMatch[1];\n    const cachebreaker = parseInt((_b = imageSrcMatch[2]) !== null && _b !== void 0 ? _b : '0');\n    const badCachebreaker = (_c = outOfDateCacheBreakers[fileUrl]) !== null && _c !== void 0 ? _c : {};\n    if (isNaN(cachebreaker) || cachebreaker <= (badCachebreaker === null || badCachebreaker === void 0 ? void 0 : badCachebreaker.outdated)) {\n        imageElem.src = `${fileUrl}?t=${badCachebreaker.suggested}`;\n    }\n    let haveWebviewApi = true;\n    try {\n        // Attempt to access .postMessage\n        // Note: We can't just check window.webviewApi because webviewApi seems not to be\n        //       a property on window.\n        haveWebviewApi = typeof webviewApi.postMessage === 'function';\n    }\n    catch (_err) {\n        haveWebviewApi = false;\n    }\n    const isRichTextEditor = !haveWebviewApi || ((_d = document.body) === null || _d === void 0 ? void 0 : _d.id) === 'tinymce';\n    if (isRichTextEditor) {\n        button === null || button === void 0 ? void 0 : button.remove();\n        imageElem.style.cursor = 'pointer';\n    }\n};\nexports[\"default\"] = (context) => {\n    return {\n        plugin: (markdownIt, _options) => {\n            const editSvgCommandIdentifier = context.contentScriptId;\n            let idCounter = 0;\n            const editImageFnString = editImage.toString().replace(/[\"]/g, '&quot;');\n            const onImgLoadFnString = onImgLoad.toString().replace(/[\"]/g, '&quot;');\n            // Ref: https://github.com/markdown-it/markdown-it/blob/master/docs/architecture.md#renderer\n            // and the joplin-drawio plugin\n            const originalRenderer = markdownIt.renderer.rules.image;\n            markdownIt.renderer.rules.image = (tokens, idx, options, env, self) => {\n                var _a;\n                const defaultHtml = (_a = originalRenderer === null || originalRenderer === void 0 ? void 0 : originalRenderer(tokens, idx, options, env, self)) !== null && _a !== void 0 ? _a : '';\n                const svgUrlExp = /src\\s*=\\s*['\"](file:[/][/]|jop[-a-zA-Z]+:[/][/])?[^'\"]*[.]svg([?]t=\\d+)?['\"]/i;\n                if (!svgUrlExp.exec(defaultHtml !== null && defaultHtml !== void 0 ? defaultHtml : '')) {\n                    return defaultHtml;\n                }\n                const buttonId = `io-github-personalizedrefrigerator-js-draw-edit-button-${idCounter}`;\n                const svgId = `io-github-personalizedrefrigerator-js-draw-editable-svg-${idCounter}`;\n                idCounter++;\n                const editCallbackJs = `(${editImageFnString})('${editSvgCommandIdentifier}', this.parentElement, '${svgId}')`;\n                const htmlWithOnload = defaultHtml.replace('<img ', `<img id=\"${svgId}\" ondblclick=\"${editCallbackJs}\" onload=\"(${onImgLoadFnString})(this.parentElement, '${buttonId}')\" `);\n                return `\n\t\t\t\t<span class='jsdraw--svgWrapper' contentEditable='false'>\n\t\t\t\t\t${htmlWithOnload}\n\t\t\t\t\t<button\n\t\t\t\t\t\tclass='jsdraw--editButton'\n\t\t\t\t\t\tonclick=\"${editCallbackJs}\"\n\t\t\t\t\t\tid=\"${buttonId}\"\n\t\t\t\t\t>\n\t\t\t\t\t\t${localization_1.default.edit} 🖊️\n\t\t\t\t\t</button>\n\t\t\t\t</span>\n\t\t\t\t`;\n            };\n        },\n        assets: () => {\n            return [{ name: 'markdownIt.css' }];\n        },\n    };\n};\n\n\n//# sourceURL=webpack://default/./src/contentScripts/markdownIt.ts?");

/***/ }),

/***/ "./src/localization.ts":
/*!*****************************!*\
  !*** ./src/localization.ts ***!
  \*****************************/
/***/ ((__unused_webpack_module, exports) => {

eval("\nObject.defineProperty(exports, \"__esModule\", ({ value: true }));\nconst defaultStrings = {\n    insertDrawing: 'Insert Drawing',\n    insertDrawingInNewWindow: 'Insert drawing in new window',\n    restoreFromAutosave: 'Restore from autosaved drawing',\n    deleteAutosave: 'Delete all autosaved drawings',\n    noSuchAutosaveExists: 'No autosave exists',\n    discardChanges: 'Discard changes',\n    defaultImageTitle: 'Freehand Drawing',\n    edit: 'Edit',\n    close: 'Close',\n    saveAndClose: 'Save and close',\n    overwriteExisting: 'Overwrite existing',\n    saveAsNewDrawing: 'Save as a new drawing',\n    clickBelowToContinue: 'Done! Click below to continue.',\n    discardUnsavedChanges: 'Discard unsaved changes?',\n    resumeEditing: 'Resume editing',\n    saveAndResumeEditing: 'Save and resume editing',\n    saveChanges: 'Save changes',\n    exitInstructions: 'All changes saved! Click below to exit.',\n    settingsPaneDescription: 'Settings for the Freehand Drawing image editor.',\n    setting__disableFullScreen: 'Dialog mode',\n    setting__disableFullScreenDescription: 'Enabling this setting causes the editor to only partially fill the Joplin window.',\n    setting__autosaveIntervalSettingLabel: 'Autosave interval (minutes)',\n    setting__autosaveIntervalSettingDescription: 'Adjusts how often a backup copy of the current drawing is created. The most recent autosave can be restored by searching for \":restore autosave\" in the command palette (ctrl+shift+p or cmd+shift+p on MacOS) and clicking \"Restore from autosaved drawing\". If this setting is set to zero, autosaves are created every two minutes.',\n    setting__themeLabel: 'Theme',\n    setting__toolbarTypeLabel: 'Toolbar type',\n    setting__toolbarTypeDescription: 'This setting switches between possible toolbar user interfaces for the image editor.',\n    setting__keyboardShortcuts: 'Keyboard shortcuts',\n    toolbarTypeDefault: 'Default',\n    toolbarTypeSidebar: 'Sidebar',\n    toolbarTypeDropdown: 'Dropdown',\n    styleMatchJoplin: 'Match Joplin',\n    styleJsDrawLight: 'Light',\n    styleJsDrawDark: 'Dark',\n    images: 'Images',\n    pdfs: 'PDFs',\n    allFiles: 'All Files',\n    loadLargePdf: (pageCount) => `A selected file is a large PDF (${pageCount} pages). Loading it may take some time and increase the size of the current drawing. Continue?`,\n    notAnEditableImage: (resourceId, resourceType) => `Resource ${resourceId} is not an editable image. Unable to edit resource of type ${resourceType}.`,\n};\nconst localizations = {\n    de: Object.assign(Object.assign({}, defaultStrings), { insertDrawing: 'Zeichnung einfügen', restoreFromAutosave: 'Automatische Sicherung wiederherstellen', deleteAutosave: 'Alle automatischen Sicherungen löschen', noSuchAutosaveExists: 'Keine automatischen Sicherungen vorhanden', discardChanges: 'Änderungen verwerfen', defaultImageTitle: 'Freihand-Zeichnen', edit: 'Bearbeiten', close: 'Schließen', overwriteExisting: 'Existierende Zeichnung überschreiben', saveAsNewDrawing: 'Als neue Zeichnung speichern', clickBelowToContinue: 'Fertig! Klicke auf „Ok“ um fortzufahen.', discardUnsavedChanges: 'Ungespeicherte Änderungen verwerfen?', resumeEditing: 'Bearbeiten fortfahren', notAnEditableImage: (resourceId, resourceType) => `Die Ressource ${resourceId} ist kein bearbeitbares Bild. Ressource vom Typ ${resourceType} kann nicht bearbeitet werden.` }),\n    en: defaultStrings,\n    es: Object.assign(Object.assign({}, defaultStrings), { insertDrawing: 'Añada dibujo', restoreFromAutosave: 'Resturar al autoguardado', deleteAutosave: 'Borrar el autoguardado', noSuchAutosaveExists: 'No autoguardado existe', discardChanges: 'Descartar cambios', defaultImageTitle: 'Dibujo', edit: 'Editar', close: 'Cerrar', saveAndClose: 'Guardar y cerrar', overwriteExisting: 'Sobrescribir existente', saveAsNewDrawing: 'Guardar como dibujo nuevo', clickBelowToContinue: 'Guardado. Ponga «ok» para continuar.', discardUnsavedChanges: '¿Descartar cambios no guardados?', resumeEditing: 'Continuar editando', saveAndResumeEditing: 'Guardar y continuar editando' }),\n};\nlet localization;\nconst languages = [...navigator.languages];\nfor (const language of navigator.languages) {\n    const localeSep = language.indexOf('-');\n    if (localeSep !== -1) {\n        languages.push(language.substring(0, localeSep));\n    }\n}\nfor (const locale of languages) {\n    if (locale in localizations) {\n        localization = localizations[locale];\n        break;\n    }\n}\nif (!localization) {\n    console.log('No supported localization found. Falling back to default.');\n    localization = defaultStrings;\n}\nexports[\"default\"] = localization;\n\n\n//# sourceURL=webpack://default/./src/localization.ts?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = __webpack_require__("./src/contentScripts/markdownIt.ts");
/******/ 	exports["default"] = __webpack_exports__["default"];
/******/ 	
/******/ })()
;