/*  Mentova — shared UI rule: pressed buttons show an inverted colour.

    STANDING RULE (see CLAUDE.md, UI BUTTON RULE): every button on every page the
    Mentova server serves must, while the mouse button is held down on it, show
    an inverted colour scheme; when the mouse button is released the colour first
    goes back to normal and THEN the action fires. Dragging off a held button
    reverts its colour without firing.

    Ordering is guaranteed by the browser's event sequence: mousedown -> mouseup
    -> click. The invert is a class this script adds on mousedown and removes on
    mouseup; the button's action runs on the click event, which is dispatched
    only after mouseup completes. So the colour is already back to normal by the
    time the action fires. The invert is driven solely by the class (not the
    browser :active state), so it cannot linger into the click.

    Every served HTML page includes this file once, just before </body>:
        <script src="/assets/common/press.js"></script>
    It is self-contained (it injects its own style), theme-agnostic (it inverts
    whatever colours the button already has), and needs no per-page CSS. New
    pages get the behaviour for free simply by including this one line.
*/
(function () {
  // Every kind of clickable control this rule applies to.
  var SEL = 'button, select, [role="button"], ' +
            'input[type="button"], input[type="submit"], input[type="reset"]';

  // Inject the pressed-state style once: inverted colours while held. The invert
  // is bound only to the .mc-pressed class (NOT the browser :active state), so
  // it is fully under this script's control and is removed on release strictly
  // before the click fires.
  var style = document.createElement('style');
  style.setAttribute('data-mc-press', '1');
  style.textContent = '.mc-pressed { filter: invert(1) !important; }';
  (document.head || document.documentElement).appendChild(style);

  // The control (if any) that an event happened on.
  function ctrl(target) {
    return (target && target.closest) ? target.closest(SEL) : null;
  }

  // Press: invert while the mouse button is held down on a control.
  document.addEventListener('mousedown', function (e) {
    var b = ctrl(e.target);
    if (b) b.classList.add('mc-pressed');
  });
  // Release anywhere: revert every pressed control (the click itself still fires).
  document.addEventListener('mouseup', function () {
    var list = document.querySelectorAll('.mc-pressed');
    for (var i = 0; i < list.length; i++) list[i].classList.remove('mc-pressed');
  });
  // Drag off a held control: revert its colour (no action, like a native click).
  document.addEventListener('mouseout', function (e) {
    var b = ctrl(e.target);
    if (b) b.classList.remove('mc-pressed');
  });
}());
