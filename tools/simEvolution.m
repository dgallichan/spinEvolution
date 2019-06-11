function out = simEvolution(inOpts)
% function out = simEvolution(inOpts)
%

% [Angles Flip_times rot_funcs t z_max z_min noSpins flip_images include_relaxation T1 T2]
opts = ...
    process_options_struct(inOpts,'Angles',90,'Flip_times',0.05,'rot_funcs',{'rotx'},'t',linspace(0,5,501),...
    'z_max',1,'z_min',[],'noSpins',200,'flip_images',160,'include_relaxation',0,'T1',1e5,'T2',2);

Angles = opts.Angles; Flip_times = opts.Flip_times; rot_funcs = opts.rot_funcs;
t = opts.t; z_max = opts.z_max; z_min = opts.z_min; noSpins = opts.noSpins; flip_images = opts.flip_images;
include_relaxation = opts.include_relaxation; T1 = opts.T1; T2 = opts.T2;

if isempty(z_min)
    z_min = z_max;
end


delta_t = t(2)-t(1);

if include_relaxation
    DecayM = [ exp(-delta_t/T2)                0               0          ;...
        0                   exp(-delta_t/T2)       0          ;...
        0                        0     1         ];
else
    DecayM = eye(3);
end

% z_per_sec = -.8:.02:.4;
%z_per_sec = randn(1,200)*.8;
if ~exist('z_min','var'),  z_min = -z_max; end
z_per_sec = linspace(z_min,z_max,noSpins);
% z_per_sec = (z_max/2)*randn(noSpins,1);
noLines = length(z_per_sec);



for i = 1:noLines
    Rz(:,:,i) = rotz(z_per_sec(i)*360*delta_t);            
end



no_flips = length(Flip_times);

M = zeros(3,length(t),noLines);
M(:,1,:) = repmat([0; 0; 1],[1 1 noLines]);

rf_tracking = zeros(length(t),1); % set to 1 for RF along x, 2 for y, 3 for z

for dt = 2:size(M,2)
   for i = 1:noLines 

%        if t(dt) < Flip_times(2)
              M(:,dt,i) = (Rz(:,:,i) * (DecayM * M(:,dt-1,i)));
%        else
%            M(:,dt,i) =  M(:,dt-1,i); %%% NO ROTATION!!!!!
%        end

%        M(3,dt,i) = 1-sqrt(M(1,dt,i)^2+M(2,dt,i)^2);
       if include_relaxation
           M(3,dt,i) = 1 - ( (1-M(3,dt,i))*exp(-delta_t/T1) );
       end
       
%        M(:,dt,i) = M(:,dt,i)/sqrt(sum3(M(:,dt,i).^2));
       
       Flip_now = (abs(t(dt)-Flip_times) < delta_t/2);
       if any(Flip_now)
           Flip_index = find(Flip_now);
           rot_func = char(rot_funcs(Flip_index));
           R = feval(rot_func,Angles(Flip_index));
           M(:,dt,i) = R * M(:,dt,i);
       end
       
       if ~include_relaxation
           M(:,dt,i) = M(:,dt,i) * sum(M(:,dt-1,i).^2)/sum(M(:,dt,i).^2);
       end
       
   end
end

dt = 1;
newtime_i = 1:length(t);
newM = M;
flip_i = 0;
while flip_i < no_flips % Attempt to do funky slow motion RF rotations
    Flip_now = (abs(t(dt)-Flip_times) < delta_t/2);

    if any( Flip_now )
        Flip_index = find(Flip_now);
       
        dt_i = dt + (flip_i*flip_images);
        newM(:,dt_i + flip_images:end+flip_images,:) = newM(:,dt_i:end,:);
        newtime_i(dt_i + flip_images:end + flip_images) = newtime_i(dt_i:end);
        newtime_i(dt_i+1:dt_i+flip_images) = newtime_i(dt_i);
                  
        rot_func = char(rot_funcs(Flip_index));
        Rbit = feval(rot_func,Angles(Flip_index)/flip_images);
        for j = 0:flip_images-1
            for i = 1:noLines
                newM(:,dt_i+j,i) = Rbit * newM(:,dt_i+j-1,i);
            end
        end
        
        switch char(rot_func)
            case 'rotx'
                rotID = 1;
            case 'roty'
                rotID = 2;
            case 'rotz'
                rotID = 3;
            otherwise
                disp('crap')
        end
        rf_tracking(end+flip_images) = 0; % extend it first
        rf_tracking(dt_i:dt_i+flip_images) = rotID;
        
        flip_i = flip_i+1;
    end
    dt = dt+1;
end

out.M = M;
out.newM = newM;
out.t = t;
out.newtime_i = newtime_i;
out.rf_tracking = rf_tracking;
out.rot_funcs = rot_funcs;
out.Flip_times = Flip_times;
out.Angles = Angles;
