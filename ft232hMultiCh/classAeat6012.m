classdef classAeat6012

    properties (Hidden)
    end
    
    properties (SetAccess = private)
    end
    
    properties (SetAccess = public)
        ver = '22.8.3';
        mpsse;
        pyObj;
    end
    
    methods
        function self = classAeat6012(mpsse_)
            self.mpsse = mpsse_;
            self.pyObj = py.Aeat6012.Aeat6012(self.mpsse);
        end

        function delete (self)
            self.mpsse.closeChannel();
        end
        
        function ret = readAsDigit(self, devCh, cs)
            ret = double(self.pyObj.readAsDigit(devCh, uint8(cs)));
        end
        function ret = readAsFloat(self, devCh, cs)
            ret = double(self.pyObj.readAsFloat(devCh, uint8(cs)));
        end
        function ret = readAsDigitAtOnce(self, devCh, CSs)
            ret = self.pyObj.readAsDigitAtOnce(devCh, self.mat2py(uint8(CSs)));
            ret = self.py2mat(ret);
        end
        function ret = readAsFloatAtOnce(self, devCh, CSs)
            ret = self.pyObj.readAsFloatAtOnce(devCh, self.mat2py(uint8(CSs)));
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
