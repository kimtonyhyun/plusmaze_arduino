last_detected_position = 0;

while (true)
    % Check prox sensors until one of them trips
    arm_idx = [];
    while isempty(arm_idx)
        arm_idx = find(maze.check_all_prox);
    end
    
    % Mouse position changed
    if (arm_idx ~= last_detected_position)
        fprintf('%s: Mouse detected at Arm %d!\n', datestr(now), arm_idx);
        maze.dose(arm_idx);
        last_detected_position = arm_idx;
    end
end