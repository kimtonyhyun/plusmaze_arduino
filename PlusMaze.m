classdef PlusMaze < handle
    properties (SetAccess=private)
        center_state
        params
    end
    
    properties (Hidden=true)
        a % Arduino object
    end
    
    methods
        function maze = PlusMaze(comPort)
            % Arduino pinout
            %------------------------------------------------------------
            p.center.step = 24; % Dir is expected to be pin "step"-2
            
            p.arm(1).dose = 49;
            p.arm(1).dose_duration = 3; % ms
            p.arm(1).num_pulses = 3;
            p.arm(1).prox = 48;
            
            p.arm(2).dose = 47;
            p.arm(2).dose_duration = 3;
            p.arm(2).num_pulses = 3;
            p.arm(2).prox = 46;
            
            p.arm(3).dose = 51;
            p.arm(3).dose_duration = 3;
            p.arm(3).num_pulses = 3;
            p.arm(3).prox = 50;
            
            p.arm(4).dose = 53;
            p.arm(4).dose_duration = 3;
            p.arm(4).num_pulses = 3;
            p.arm(4).prox = 52;
            
            p.num_arms = length(p.arm);

            % Synchronization outputs
            p.sync.miniscope_trig = 13;
            
            maze.center_state = 0;
            maze.params = p;
            
            % Establish access to Arduino
            %------------------------------------------------------------
            maze.a = arduino(comPort);

            % Set up digital pins
            maze.a.pinMode(maze.params.center.step, 'output');
            maze.a.pinMode(maze.params.center.step-2, 'output'); % dir
            
            for i = 1:maze.params.num_arms
                ar = maze.params.arm(i);
                maze.a.pinMode(ar.dose, 'output');
                maze.a.pinMode(ar.prox, 'input');
            end
            
            maze.a.pinMode(maze.params.sync.miniscope_trig, 'output');
        end
        
        function is_present = check_prox(maze, arm_idx)
            prox_pin = maze.params.arm(arm_idx).prox;
            is_present = ~maze.a.digitalRead(prox_pin);
        end
        
        % Reward controls
        %------------------------------------------------------------
        function dose(maze, arm_idx, dose_duration, num_pulses)
            if ~exist('dose_duration', 'var') % Use default
                dose_duration = maze.params.arm(arm_idx).dose_duration;
            end
            if ~exist('num_pulses', 'var')
                num_pulses = maze.params.arm(arm_idx).num_pulses;
            end
            
            dose_pin = maze.params.arm(arm_idx).dose;
            for k = 1:num_pulses
                maze.a.send_pulse(dose_pin, dose_duration);
                pause(0.01);
            end
        end
        
        function prime(maze, arm_idx)
            dose_pin = maze.params.arm(arm_idx).dose;
            maze.a.digitalWrite(dose_pin, 1);
            pause(1); % seconds
            maze.a.digitalWrite(dose_pin, 0);
        end
        
%         function lick = is_licking(maze, track_idx)
%             lick_pin = maze.params.track(track_idx).lick;
%             lick = maze.a.digitalRead(lick_pin);
%         end
        
        function set_center(maze, target)
            % Target may be: 0, 0.5, 1, 1.5
            target = max(0, target); % If target < 0, set to 0
            target = min(1.5, target); % If target > 1.5, set to 1.5
            
            step_pin = maze.params.center.step;
            current = maze.center_state;
            if (target ~= current)
                direction = (target > current);
                num_90degs = abs(target-current)*2;
                maze.a.rotate_stepper(step_pin, direction, num_90degs);
            end
            
            maze.center_state = target;
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