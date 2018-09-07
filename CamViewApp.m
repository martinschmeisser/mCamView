classdef CamViewApp < handle
    %CAMVIEWAPP a matlab app to acquire images
    %   This app uses Basler's Pylon C++ API to acquire images from a GiGE
    %   Vision compatible camera. Basic analysis can be performed and
    %   images can be saved in full resolution and pixel depth.
    
    
    % /*
    %  *  definition of camera info array
    %  *  uint16_t Info
    %  *      1   x                   0
    %  *      2   y                   1
    %  *      3   size in bytes       2
    %  *      4   exposure min        3
    %  *      5   exposure max        4
    %  *      6   exposure value      5
    %  *      7   gain min            6
    %  *      8   gain max            7
    %  *      9   gain value          8
    %  *     10   black level min     9
    %  *     11   black level max     10
    %  *     12   black level value   11
    %  *
    %  *      matlab index            c index
    %  *
    %  */
    
    properties
        Figure                  %graphics handles
        
        imageAxes
        verticalAxes
        horizontalAxes
        Himage
        
        controlsPanel
        acquireButton
        analyzeButton
        contiButton
        flipCheckbox
        exposureTimeSlider
        gainSlider
        blackLevelSlider
        label1, label2, label3
        
        hProxy                  %handle to C++ Pylon API Proxy
        Info                    %image controls
        acquireContiunously
        %buffers
        
        roiX, roiY, roiWidth, roiHeight
        roiSet
        
        radialApp
        currentImage
        
    end
    
    methods
        function app = CamViewApp %constructor
            
            [app.hProxy, app.Info] = PylonSetup;    %instantiate Pylon Proxy class
                                                    %and store handle
            app.Figure = figure('MenuBar', 'none', 'NumberTitle', 'off',...
                'Name', 'CamView', 'CloseRequestFcn', @app.closeApp,...
                'Position', [520 307 872 495]);
            app.imageAxes =      axes('Parent', app.Figure, 'Units', 'centimeters', 'Position', [8 4.5 12 8], 'ButtonDownFcn', {@app.ax_ButtonDown});
            hold on;
            app.verticalAxes =   axes('Parent', app.Figure, 'Units', 'centimeters', 'Position', [20.75 4.5 2 8]);
            app.horizontalAxes = axes('Parent', app.Figure, 'Units', 'centimeters', 'Position', [8 1.75 12 2]);
            
            app.controlsPanel = uipanel('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 0.5 5 5],...
                'Title', 'camera controls');
            
            app.exposureTimeSlider = uicontrol('Parent', app.controlsPanel, 'Units', 'centimeters', 'Position', [0.5 2.5 4 0.5], 'Style', 'slider', 'Min',  app.Info(1,4),  'Max', app.Info(1,5),  'Value',  app.Info(1,6), 'Callback', {@app.slider_Callback});
            app.gainSlider         = uicontrol('Parent', app.controlsPanel, 'Units', 'centimeters', 'Position', [0.5 1.5 4 0.5], 'Style', 'slider', 'Min',  app.Info(1,7),  'Max', app.Info(1,8),  'Value',  app.Info(1,9), 'Callback', {@app.slider_Callback});
            app.blackLevelSlider   = uicontrol('Parent', app.controlsPanel, 'Units', 'centimeters', 'Position', [0.5 0.5 4 0.5], 'Style', 'slider', 'Min',  app.Info(1,10), 'Max', app.Info(1,11), 'Value',  app.Info(1,12), 'Callback', {@app.slider_Callback});
            app.label1             = uicontrol('Parent', app.controlsPanel, 'Units', 'centimeters', 'Position', [0.5 3 4 0.5],   'Style', 'text', 'String', 'exposure time');
            app.label2             = uicontrol('Parent', app.controlsPanel, 'Units', 'centimeters', 'Position', [0.5 2 4 0.5],   'Style', 'text', 'String', 'gain');
            app.label3             = uicontrol('Parent', app.controlsPanel, 'Units', 'centimeters', 'Position', [0.5 1 4 0.5],   'Style', 'text', 'String', 'black level');
            
            app.flipCheckbox  = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 8 2.5 0.5], 'Style', 'checkbox', 'String', 'flip image');
            app.acquireButton = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 10 2 0.75], 'Style', 'pushbutton', 'String', 'acquire once', 'Callback', {@app.acquireButton_Callback});
            app.analyzeButton = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 9  2 0.75], 'Style', 'pushbutton', 'String', 'analyze', 'Callback', {@app.analyzeButton_Callback});
            app.contiButton   = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 11 2 0.75], 'Style', 'togglebutton', 'String', 'continuous', 'Callback', {@app.contiButton_Callback});
            app.roiSet = 0;
            app.radialApp = 0;      
            
            axes(app.imageAxes);
            A = zeros(app.Info(1,2), app.Info(1,1));
            app.Himage = image(A);            
            set(gca,'Units','pixels')
            xlim([1 app.Info(1,1)]);
            ylim([1 app.Info(1,2)]);
            
            set(gca, 'xlimmode','manual', 'ylimmode','manual', 'zlimmode','manual',...
                     'climmode','manual', 'alimmode','manual');
                 
            xlim(app.horizontalAxes, [1 app.Info(1,1)]);
            ylim(app.verticalAxes,   [1 app.Info(1,2)]);
        end
        
        function closeApp(app, ~, ~)
            PylonEnd(app.hProxy)
            if (app.radialApp ~= 0)
                %app.radialApp.closeApp(app.radialApp);
            end
            delete(app.Figure)
        end
        
        function ax_ButtonDown(app, ~, ~)
            if (app.roiSet == 1)
                P = get(app.imageAxes, 'CurrentPoint');

                app.roiSet = 0;
                app.roiX = P(1);
                app.roiY = P(3);
                app.roiWidth = 10;
                app.roiHeight = 10;
                disp(app.roiSet);
            else
                P = get(app.imageAxes, 'CurrentPoint');

                app.roiSet = 1;
                app.roiWidth = abs(P(1)-app.roiX);
                app.roiHeight = abs(P(3)-app.roiY);
                axes(app.imageAxes);
                hold on
                line('XData',[app.roiX app.roiX+app.roiWidth],'YData',[app.roiY app.roiY],'Color','r')
                line('XData',[app.roiX app.roiX+app.roiWidth],'YData',[app.roiY+app.roiHeight app.roiY+app.roiHeight],'Color','r')
                line('XData',[app.roiX app.roiX],'YData',[app.roiY app.roiY+app.roiHeight],'Color','r')
                line('XData',[app.roiX+app.roiWidth app.roiX+app.roiWidth],'YData',[app.roiY app.roiY+app.roiHeight],'Color','r')
                hold off
                
                disp(app.roiSet);
            end
            disp(app.roiSet);
        end
        
        
        
        % --- Executes on button press in acquireButton.
        function acquireButton_Callback(app, ~, ~)
        % app    handle to acquireButton (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
            A=double(PylonUse(app.hProxy)').*64./4095;
            axes(app.imageAxes);
            if (get(app.flipCheckbox, 'Value') == 1.0)
                A=rot90(A,2);
            end
            set(app.Himage, 'Cdata', A);
            drawnow;
                        
            x=size(A,1):-1:1;          y=sum(A,2);
            [s,mu,Amp]=mygaussfit(x,y);
            plot(app.verticalAxes, y, x);          hold(app.verticalAxes,'on');
            y=Amp*exp(-(x-mu).^2/(2*s^2));
            plot(app.verticalAxes, y, x, '-r');    hold(app.verticalAxes,'off');
            
            x=1:size(A,2);            y=sum(A,1);
            [s,mu,Amp]=mygaussfit(x,y);
            plot(app.horizontalAxes, x, y);        hold(app.horizontalAxes,'on');
            y=Amp*exp(-(x-mu).^2/(2*s^2));
            plot(app.horizontalAxes, x, y, '-r');  hold(app.horizontalAxes,'off');
            
            assignin('base', 'img', A);
            app.currentImage = A;
            
            if (app.roiSet == 0)
                app.roiX = 1;
                app.roiY = 1;
                app.roiWidth = app.Info(1);
                app.roiHeight = app.Info(2);
            end
        end
        
        
        
        function analyzeButton_Callback(app, ~, ~)
            if (app.radialApp == 0)
                app.radialApp = RadialDistributionApp;
            end
            app.radialApp.newImage(app.currentImage);
            axes(app.imageAxes);
        end
        
        
        
        function contiButton_Callback(app, ~, ~)
            if (get(app.contiButton,'Value') == 1)
                
                if (app.roiSet == 0)
                    app.roiX = 1;
                    app.roiY = 1;
                    app.roiWidth = app.Info(1);
                    app.roiHeight = app.Info(2);
                end
                
                % set status and trigger the pylon proxy to start grabbing
                app.acquireContiunously = 1;
                buffers = PylonStartCont(app.hProxy, 10);

                axes(app.imageAxes);
                pause on;
                
                count = 1;                
                while (app.acquireContiunously == 1)
                    count = count +1;
                    
                    %get a new frame from pylon proxies ring buffer
                    num = PylonGetFrame(app.hProxy);
                    if (num < 0)
                        warning('dropped a frame!');
                        continue;
                    end
                    
                    %draw only every second image
                    if (mod(count,2) == 0)
                        %NOTE conversion to double and transpose takes most of the time here
                        A = double(reshape(buffers(:,num+1), app.Info(1,1), app.Info(1,2)))'.*64./4095;
                        if (get(app.flipCheckbox, 'Value') == 1.0)
                            A=rot90(A,2);
                        end
                        set(app.Himage, 'Cdata', A);
                        drawnow;

                        plot(app.verticalAxes, sum(A,2), 1:size(A,1));
                        plot(app.horizontalAxes, size(A,2):-1:1, sum(A));
                    end

                    PylonReQ(app.hProxy, num);
                    if (mod(count,100) == 0)
                        count = 0;
                        %pause(0.1); %safety pause to make sure other callbacks get their chance
                    end
                end
                PylonStopCont(app.hProxy, buffers);
            else
                app.acquireContiunously = 0;
            end
                app.acquireContiunously = 0;
        end
        
        
        
        function slider_Callback(app, ~, ~)
        % Hints: get(app,'Value') returns position of slider
        %        get(app,'Min') and get(app,'Max') to determine range of slider
            app.Info(1,6)  = get(app.exposureTimeSlider,'Value');
            app.Info(1,9)  = get(app.gainSlider,'Value');
            app.Info(1,12) = get(app.blackLevelSlider,'Value');
            PylonSetInfo(app.hProxy,app.Info);
        end
    end
    
end

