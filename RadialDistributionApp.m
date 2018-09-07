classdef RadialDistributionApp < handle
    %RadialDistributionApp performs an azimuthal integration of intensity
    %values around the center of gravity in an image
    
    properties
        Figure                  %graphics handles
        
        imageAxes
        horizontalAxes        
        testImageButton
        sigmaLabel
        numBinsEdit
        numSigmaEdit
        
        input_image
        referenceDistribution
    end
    
    methods
        function app = RadialDistributionApp %constructor
            
            app.Figure = figure('MenuBar', 'none', 'NumberTitle', 'off',...
                'Name', 'Radial Distribution', 'CloseRequestFcn', @app.closeApp,...
                'Position', [520 307 1000 500]);
            app.imageAxes =      axes('Parent', app.Figure, 'Units', 'centimeters', 'Position', [1  1 12 8]);
            app.horizontalAxes = axes('Parent', app.Figure, 'Units', 'centimeters', 'Position', [14 1 12 8]);
            
            app.testImageButton = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 10.5 2 0.75], 'Style', 'pushbutton', 'String', 'test image 1', 'Callback', {@app.testImageButton_Callback});
            app.sigmaLabel = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [3.5 10.5 6 0.5], 'Style', 'text', 'String', 'rms width is --- px');
            uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [0.5 9.5 8.5 0.5], 'Style', 'text', 'String', 'Integrate over                  rms widths using                   bins.');
            app.numSigmaEdit  = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [3.0 9.5 1 0.75], 'Style', 'edit', 'String', '1.5');
            app.numBinsEdit   = uicontrol('Parent', app.Figure, 'Units', 'centimeters', 'Position', [6.5 9.5 1 0.75], 'Style', 'edit', 'String', '35');
            
            app.referenceDistribution = @(x)my_normpdf(x, 0.0, 50);
            %app.referenceDistribution = @(x) (-(x-10).*(x-15).*(x-300));
            set(0, 'defaultTextInterpreter', 'latex'); 
        end
        
        function closeApp(app, ~, ~)
            delete(app.Figure)
        end
        
        function radialIntegration(app)
            [sigma_y, center_y, ~] = mygaussfit(1:494, sum(app.input_image), 0.1);
            [sigma_x, center_x, ~] = mygaussfit(1:659, sum(app.input_image, 2), 0.1);


            % number of integration bins
            N = floor(str2double(get(app.numBinsEdit, 'String')));
            % how far should the integration extend in units of sigma
            %num_sigmas = str2double(get(app.numSigmaEdit, 'String'));
            
            max_dist = min([center_x center_y 659-center_x 494-center_y]);

            sigma = (sigma_x + sigma_y) / 2;
            set(app.sigmaLabel, 'String', sprintf('rms width is %.1f px (sum est.)', sigma));
            bin_distance = max_dist/N;
            set(app.numSigmaEdit, 'String', sprintf('%.1f', max_dist/sigma));

            bins = zeros(1,N);
            disp([center_x center_y sigma]);
            
            noise_estimate = 0;
            noise_count = 0;
            
            bin_image = zeros(659, 494);

            for k = 1:659
                for j=1:494
                    bin = floor(sqrt((k-center_x)^2+(j-center_y)^2)/bin_distance)+1;
                    bin_image(k,j) = bin;
                    %if (bin == 0); bin = 1; end
                    if (bin <= N)
                        bins(bin) = bins(bin) + app.input_image(k,j);
                    end
                    if (bin == N)
                        noise_estimate = noise_estimate + app.input_image(k,j);
                        noise_count = noise_count +1;
                    end
                end
            end
            %plot(((1:N)-0.5)*bin_distance, bins);
            %hold on;
                        
            disp(noise_estimate);
            disp(noise_count);

            %subtract extimated noise level
            noise_estimate = noise_estimate / noise_count;
            disp(noise_estimate);
            if (noise_estimate > 0)
                %bins(1) = bins(1) / (pi*0.25*bin_distance^2*noise_estimate);
                for k = 1:N
                    bins(k) = bins(k) - (pi*(2*k-1)*bin_distance^2*noise_estimate);
                end
            end
            %plot(((1:N)-0.5)*bin_distance, bins);
            %normalize by bin area
            %bins(1) = bins(1) / (pi*0.25*bin_distance^2);
            for k = 1:N
                bins(k) = bins(k) / (pi*(2*k-1)*bin_distance^2);
            end
                                                        
            bins = bins / (2*sum(bins)*bin_distance);   %normalize to unity

            %image(bin_image);
            
            axes(app.horizontalAxes);
            plot(((1:N)-0.5)*bin_distance, bins , ((1:N)-0.5)*bin_distance, app.referenceDistribution(((1:N)-0.5)*bin_distance) );
            ylim([0 1.2*max(bins)]);
        end
        
        function testImageButton_Callback(app, ~, ~)
            [iimage] = zeros(659, 494);
            refDist = app.referenceDistribution;
            noise_level = 15;
            for k = 1:659
                for j=1:494
                    dist = sqrt((k-350)^2+(j-250)^2);
                    iimage(k,j) = noise_level*rand(1);
                    if (dist < 150)
                        iimage(k,j) = iimage(k,j) + 2000*refDist(dist); 
                        %app.input_image(k,j) = app.input_image(k,j) + 50;
                    end
                end
            end
            %[app.input_image] = evalin('base', 'img');
            
            axes(app.imageAxes);
            image(double(iimage')/max(max(double(iimage)))*64.0);
            xlim([0 659]);
            ylim([0 494]);
            
            app.input_image = iimage;
            radialIntegration(app);
            assignin('base', 'img', app.input_image);
            %set(app.sigmaLabel, 'String', sprintf('sigma px, SNR %.1f dB', 10*log10(2000*app.referenceDistribution(0)/noise_level)));
            %J = deconvwnr(app.input_image, 
        end
        
        function newImage(app, img)
            [app.input_image] = img;
            
            axes(app.imageAxes);
            image(double(app.input_image')./double(max(max(app.input_image))).*64);
            xlim([0 659]);
            ylim([0 494]);
            
            radialIntegration(app);
        end
        
    end
    
end

