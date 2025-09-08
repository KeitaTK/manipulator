py.pygame.init();
if double(py.pygame.joystick.get_count())
    joy = py.pygame.joystick.Joystick(int8(0));
    joy.init();

    py.pygame.event.pump();
    startButton = double(joy.get_button(int8(7)));
    bButton = double(joy.get_button(int8(0)));
    lStick = [joy.get_axis(int8(0)); joy.get_axis(int8(1))];
    rStick = [joy.get_axis(int8(3)); joy.get_axis(int8(4))];
else
    exit_flag = 1;
end
