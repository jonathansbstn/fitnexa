// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void webEval(String code) {
  try {
    html.window.console.log(''); // ensure html is accessible
    // ignore: avoid_dynamic_calls
    (html.window as dynamic).eval(code);
  } catch (_) {}
}
