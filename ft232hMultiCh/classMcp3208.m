classdef classMcp3208

    properties (Hidden)
    end
    
    properties (SetAccess = private)
    end
    
    properties (SetAccess = public)
        ver = '22.7.26';
        % analogReadAsDigitAtOnce
        % analogReadAsFloatAtOnce
        % ‚ª‚¨‚©‚µ‚¢
        mpsse;
        pyObj;
        cs;
    end
    
    methods
        function self = classMcp3208(mpsse_)
            self.mpsse = mpsse_;
            self.pyObj = py.Mcp3208.Mcp3208(self.mpsse);
        end

        function delete (self)
            self.mpsse.closeChannel();
        end
        
        function ret = analogReadAsDigit(self, devCh, cs, AdCh)
            ret = double(self.pyObj.analogReadAsDigit(devCh, py.int(cs), uint8(AdCh)));
        end
        function ret = analogReadAsFloat(self, devCh, cs, AdCh)
            ret = double(self.pyObj.analogReadAsFloat(devCh,py.int(cs), uint8(AdCh)));
        end
        function ret = analogReadAsDigitAtOnce(self, devCh, cs, AdChs)
            ret = self.pyObj.analogReadAsDigitAtOnce(devCh, uint8(cs), self.mat2py(uint8(AdChs)));
            ret = self.py2mat(ret);
        end
        function ret = analogReadAsFloatAtOnce(self, devCh, cs, AdChs)
            ret = self.pyObj.analogReadAsFloatAtOnce(devCh, uint8(cs), self.mat2py(uint8(AdChs)));
            ret = self.py2mat(ret);
        end

    end % methods
    methods (Access = protected, Static)
        function ret = mat2py( arg )
            ret = py.list(arg');
        end
        function ret = py2mat( arg )
            arg = cell(arg);
            n = length(arg);
            ret = zeros(n, 1);
            for ii=1:n
                ret(ii) = double(arg{ii});
            end
        end
    end % methods (Access = protected, Static)
    methods(Static)
    end % methods(Static)
end % classdef
