classdef PlusMaze < handle
    properties (SetAccess=private)
        params
    end
    
    properties (Hidden=true)
        a % Arduino object
    end
    
    methods
        function maze = PlusMaze(comPort)
            % Arduino pinout
            %------------------------------------------------------------
            p.arm(1).dose = 49;
            p.arm(1).dose_duration = 25; % ms
            
            p.arm(2).dose = 47;
            p.arm(2).dose_duration = 25;
            
            p.arm(3).dose = 51;
            p.arm(3).dose_duration = 25;
            
            p.arm(4).dose = 53;
            p.arm(4).dose_duration = 25;
            
            p.num_arms = length(p.arm);

            % Synchronization outputs
            p.sync.miniscope_trig = 13;
            
            maze.params = p;
            
            % Establish access to Arduino
            %------------------------------------------------------------
            maze.a = arduino(comPort);

            % Set up digital pins
            for i = 1:maze.params.num_arms
                ar = maze.params.arm(i);
                maze.a.pinMode(ar.dose, 'output');
            end
            
            maze.a.pinMode(maze.params.sync.miniscope_trig, 'output');
        end
        
        % Reward controls
        %------------------------------------------------------------
        function dose(maze, arm_idx)
            dose_pin = maze.params.arm(arm_idx).dose;
            dose_duration = maze.params.arm(arm_idx).dose_duration;
            maze.a.send_pulse(dose_pin, dose_duration);
        end
        
%         function lick = is_licking(maze, track_idx)
%             lick_pin = maze.params.track(track_idx).lick;
%             lick = maze.a.digitalRead(lick_pin);
%         end
        
        function target = set_stepper(maze, step_pin, current, target)
            % FIXME: Adapt to PlusMaze center platform
            % target == 0: Go to steel plate
            % target == 0.5: 90 deg
            % target == 1: Go to mesh
            target = max(0, target); % If target < 0, set to 0
            target = min(1, target); % If target > 1, set to 1
            
            if (target ~= current)
                direction = (target > current);
                num_90degs = abs(target-current)*2;
                maze.a.rotate_stepper(step_pin, direction, num_90degs);
            end
        end
        
        % Synchronization
        %------------------------------------------------------------
        function miniscope_start(maze)
            maze.a.digitalWrite(maze.params.sync.miniscope_trig, 1);
        end
        
        function miniscope_stop(maze)
            maze.a.digitalWrite(maze.params.sync.miniscope_trig, 0);
        end
    end
end