%%% simpleRFanimations
%%% ---
%%% Code to create animated visualisations of spin dynamics for a Hahn
%%% Echo, a simple spin echo and a stimulated echo.
%%%
%%% Code was first created years ago. Put on GitHub for easier sharing June
%%% 2019.
%%%
%%% Daniel Gallichan
%%% gallichand@cardiff.ac.uk 

saveMovie = 0; % set to one to save out animation frames
savedir='~/temp/mov'; % temporary folder to save animation frames to

addpath export_fig
addpath arrow

%%% Hahn Echo:
hahnopts.Angles = [90 90];
hahnopts.Flip_times = [0, 1];
hahnopts.rot_funcs(1:2) = {'rotx'};
hahnopts.t = linspace(-.05,2,501); 
hahnopts.z_max = .5; hahnopts.z_min =-hahnopts.z_max;
hahnopts.flip_images = 40; % no of frames during RF pulse itself

% % Simple Spin Echo:
SEopts.Angles = [90 180];
SEopts.Flip_times = [0, 1];
SEopts.rot_funcs(1) = {'rotx'};
SEopts.rot_funcs(2) = {'roty'};
SEopts.t = linspace(-.05,3.5,501);
SEopts.z_max = .5; SEopts.z_min = -SEopts.z_max;
SEopts.noSpins = 500;
SEopts.flip_images = 40;

%%% Stimulated echo
stimEcho.Angles = [90 90 90];
stimEcho.Flip_times = [0, .5, 1.5];
stimEcho.rot_funcs(1:3) = {'rotx'};
stimEcho.t = linspace(-0.05,3.5,501);
stimEcho.z_max = 5; stimEcho.z_min = -stimEcho.z_max;
stimEcho.noSpins = 500;
stimEcho.flip_images = 40;


sim = simEvolution(hahnopts);
% sim = simEvolution(SEopts); % <-- use this line for SE
% sim = simEvolution(stimEcho); % <-- use this line for stimulated echo
M = sim.M; newM = sim.newM; newtime_i = sim.newtime_i; t = sim.t; rf_tracking = sim.rf_tracking; rot_funcs = sim.rot_funcs; Flip_times = sim.Flip_times; Angles = sim.Angles;

meanSignalY = mean(M(2,:,:),3);
meanSignalX = mean(M(1,:,:),3);

x0 = [-1  0  0; 1  0  0];
y0 = [ 0 -1  0; 0  1  0];
z0 = [ 0  0 -1; 0  0  1];

figure
set(gcf,'color','w')
set(gcf,'Position',[ 241    98   758   840])

TopAxis = subplot(211);
BottomAxis = subplot(212);

set(TopAxis,'Position',[      -0.068    0.005  1.17 1.17]);
set(BottomAxis,'Position',[      0.0354    0.0435    0.9511    0.1714 ]);

subplot(TopAxis)
Az = +37.5-90; El = 30;
view(Az,El);

lw = 1.5;

M = newM;
imCount = 1;

rf_flash = 1;

no_flips = length(Flip_times);

animate = 1;
animSkip = 4;

if animate
    for dt = 1:animSkip:size(M,2)

        subplot(TopAxis)

        cla
         x = squeeze(M(1,dt,:));
        y = squeeze(M(2,dt,:));
        z = squeeze(M(3,dt,:));
        vertices = [0 0 0; x y z];
        faces = ones(length(x)-1,3);
        faces(:,2) = 2:length(x);
        faces(:,3) = 3:length(x)+1;
        colordata = repmat(linspace(0,1,length(faces))',[1 3]);
        colordata(:,1) = colordata(end:-1:1,1);
        colordata(:,2) = 0;
   
        patch('vertices',vertices,'faces',faces,'facevertexcdata',colordata,'facecolor','flat','edgecolor','none')
        view(Az,El)
        axSize = 1.2;
        showAxis3d(axSize)
        set(gca,'DataAspectRatioMode','Manual','DataAspectRatio',[1 1 1])
        axis vis3d
        axis off
        hold all
        linesToPlot = vertices(2:10:end,:);
        nLP = size(linesToPlot,1);
        zLP = zeros(nLP,1);
        for iL = 1:nLP
            line([0 linesToPlot(iL,1)],[0 linesToPlot(iL,2)],[0 linesToPlot(iL,3)],'linewidth',1,'color','k')
        end
                
        rf_flash = -rf_flash;
        if rf_flash > 0
            aColor = [13 151 21]/255;
            rotlstyle = {'linewidth',5,'color',aColor};
        else
            aColor = [13 90 21]/255;
            rotlstyle = {'linewidth',5,'color',aColor};
        end
        if (rf_flash) && (rf_tracking(dt))
            switch rf_tracking(dt)
                case 1
                      aFinish = [1 0 0];
                      aNormal = [0 0 1];
                case 2
                      aFinish = [0 1 0];
                      aNormal = [0 0 1];
                case 3
                      aFinish = [0 0 1];
                      aNormal = [1 0 0];
            end
            arrow([0 0 0],aFinish,50,'BaseAngle',90,'tipangle',30,'width',20,'normaldir',aNormal,'facecolor',aColor)            
        end
        

        subplot(BottomAxis)
        cla
        hold on
        box on
        grid on
        set(gca,'linewidth',1)
        plot(t,meanSignalY,'linewidth',lw)
        plot(t(newtime_i(dt)),meanSignalY(newtime_i(dt)),'o','linewidth',lw)
        for flip_i = 1:no_flips
            plot([Flip_times(flip_i) Flip_times(flip_i)],[-1 1],'--k','linewidth',2)
            rotaxis = char(rot_funcs(flip_i)); rotaxis = rotaxis(end);   
            text(Flip_times(flip_i), 1.25, [num2str(Angles(flip_i)),'^\circ_', rotaxis],'HorizontalAlignment','center','fontsize',16)
        end
        
        if (rf_tracking(dt) > 0) && (rf_flash)
            line([t(newtime_i(dt)) t(newtime_i(dt))],[-1 1],rotlstyle{:});
        end
        
        line([min(t) max(t)],[0 0],'color','k','linewidth',2)
        axis([min(t) max(t) -1.01 1.01])
        set(gca,'xticklabel',[],'yticklabel',[])            

        drawnow
        
        if saveMovie
            numString = num2str(imCount);
            if length(numString)==1
                numString = ['00',numString];
            end
            if length(numString)==2
                numString = ['0',numString];
            end
            FileName = ['mov',numString];

            export_fig([savedir '/' FileName],'-nocrop')
            imCount = imCount + 1;

        end
        
    end
end


