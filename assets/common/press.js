/*  Mentova — shared UI rule: pressed buttons show an inverted colour.

    STANDING RULE (see CLAUDE.md, UI BUTTON RULE): every button on every page the
    Mentova server serves must, while the mouse button is held down on it, show
    an inverted colour scheme; when the mouse button is released the colour goes
    back to normal and the action is taken (the normal click, which fires on
    release). Dragging off a held button reverts its colour without firing.

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

  // Inject the pressed-state style once: inverted colours while held.
  var active = SEL.split(',').map(function (s) { return s.trim() + ':active'; }).join(', ');
  var style = document.createElement('style');
  style.setAttribute('data-mc-press', '1');
  style.textContent = active + ', .mc-pressed { filter: invert(1) !important; }';
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
