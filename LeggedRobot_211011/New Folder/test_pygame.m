clear;

% https://www.pygame.org/docs/ref/joystick.html

py.pygame.init();
joy = py.pygame.joystick.Joystick(int8(0));
joy.init();
% py.pygame.joystick.get_count();


py.pygame.event.pump();
joy.get_axis(int8(0)); % double
startButton = double(joy.get_button(int8(7)));
while startButton==0
    py.pygame.event.pump();
    startButton = double(joy.get_button(int8(7)));
    lStick = [joy.get_axis(int8(0)); joy.get_axis(int8(1))];
    rStick = [joy.get_axis(int8(3)); joy.get_axis(int8(4))];
    fprintf('Left:%.2f, %.2f, Right:%.2f, %.2f\n', lStick(1), lStick(2), rStick(1), rStick(2));
    pause(0.1);
end