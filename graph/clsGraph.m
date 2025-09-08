% Copyright (c) 2019 ume
% Released under the MIT license
% https://opensource.org/licenses/mit-license.php
classdef clsGraph < handle
    properties (Hidden)
    end
    
    properties (SetAccess = private)
    end
    
    properties (SetAccess = public)
        figNum;
        figGrid;
        fig;
        ax;
        lines = {};
        legendsTxt = {};
        legends;
        lineNum = 0;
        style = {'-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.', ...
                 '-', '--', ':', '-.'};
        color = [0.0000    0.4470    0.7410;
                 0.8500    0.3250    0.0980;
                 0.9290    0.6940    0.1250;
                 0.4940    0.1840    0.5560;
                 0.4660    0.6740    0.1880;
                 0.3010    0.7450    0.9330;
                 0.6350    0.0780    0.1840;
                 0.0000    0.4470    0.7410; %loop
                 0.8500    0.3250    0.0980;
                 0.9290    0.6940    0.1250;
                 0.4940    0.1840    0.5560;
                 0.4660    0.6740    0.1880;
                 0.3010    0.7450    0.9330;
                 0.6350    0.0780    0.1840;
                 0.0000    0.4470    0.7410; %loop
                 0.8500    0.3250    0.0980;
                 0.9290    0.6940    0.1250;
                 0.4940    0.1840    0.5560;
                 0.4660    0.6740    0.1880;
                 0.3010    0.7450    0.9330;
                 0.6350    0.0780    0.1840    ];
        
        legFontSize = 16;
        labFontSize = 20;
        axFontSize = 20;
        axLineWidth = 2;
        lineWidth = 3;
        figWidth = 600;
        figHeight = 300;
        legType = {'northeast', 'southeast', 'northwest', 'southwest'};
        legPos = '';
    end
%{
    % Define an event called InsufficientFunds
    events
        InsufficientFunds 
    end
%}
    methods
        function self = clsGraph(figNum_)
            self.fig = figure(figNum_);
            clf;
            self.ax = gca;
            hold(self.ax, 'on');
            self.setSize(self.figWidth, self.figHeight);
            self.setAxes(self.axFontSize, self.axLineWidth);

            self.figNum = figNum_-1;
            self.figGrid = zeros(2,1);
            self.figGrid(1) = floor(self.figNum/3);
            self.figGrid(2) = self.figNum - 3*floor(self.figNum/3);
%             disp(self.figGrid);
            self.fig.PaperPositionMode = 'auto';
            pos = self.fig.Position;
            pos(1) = 0 + self.figGrid(1)*(self.figWidth+10);
            pos(2) = 100 + self.figGrid(2)*(self.figHeight+100);
            self.fig.Position = pos;
        end
        
        function ret = plot(self, x, y)
            self.lineNum = self.lineNum + 1;
            self.lines{self.lineNum} = plot(self.ax, x, y);
            self.lines{self.lineNum}.LineWidth = self.lineWidth;
            if self.lineNum <= length(self.color)
                self.lines{self.lineNum}.LineStyle = self.style{self.lineNum};
                self.lines{self.lineNum}.Color = self.color(self.lineNum,:);
            end
            ret = self.lines{self.lineNum};
        end
                
        function setSize(self, width, height)
            self.fig.PaperPositionMode = 'auto';
            pos = self.fig.Position;

            pos(3)=width-1; %‚È‚º‚©•‚ª1px‘‚¦‚é‚Ì‚Å‘Îˆ
            pos(4)=height;
            self.fig.Position = pos;
        end
        
        function setLabel(self, xL, yL)
            xlabel_h = xlabel(self.ax, xL);
            ylabel_h = ylabel(self.ax, yL);
            xlabel_h.FontSize = self.labFontSize;
            ylabel_h.FontSize = self.labFontSize;
            xlabel_h.Interpreter = 'latex';
            ylabel_h.Interpreter = 'latex';
        end
       
        function setLegends(self, leg)
%             for ii=1:self.lineNum
%                 self.legends{ii} = '';
%             end
            for ii=1:length(leg)
                self.legendsTxt{ii} = leg{ii};
            end
            self.legends = legend(self.legendsTxt);
            self.legends.FontSize = self.legFontSize;
            self.legends.Interpreter = 'latex';
        end
        
        function setLegendsPos(self, pos)
            self.legPos = pos;
            self.legends.Location = pos;
        end
        
        function setAxes(self, fontSize, lineWidth)
            self.ax.FontSize = fontSize;
            self.ax.FontName = 'Times';
            self.ax.LineWidth = lineWidth;
        end
       
        function print(self, filename)
            print(self.fig, filename, '-dpdf', '-bestfit');
        end
       
        function fitYLim(self, varargin)
            % nargin | narginchk | varargout
            lim = zeros(1,2*nargin);
            for ii=1:nargin-1
                lim(1+2*(ii-1):2+2*(ii-1)) = varargin{ii}.YLim;
            end
            for ii=1:nargin-1
                varargin{ii}.YLim = [min(lim),max(lim)];
            end
        end
       
%{
xlim(a);
xlim([floor(min(g_x(:,4))), ceil(max(g_x(:,4)))]);
xlim([min(g_x(:,3+k)), max(g_x(:,3+k))]);
self.ax.YLim = [a(1)-0.05*norm(a), a(2)+0.2*norm(a)];
%}
    end % methods
end % classdef
