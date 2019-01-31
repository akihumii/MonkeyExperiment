classdef getScaleFun
%GETSCALEFUN Returns a temporary sensor scaling function.
%   scale = sdaq.getScaleFun(sensor) returns a temporary scaling function
%   for the specified <a href="matlab:help sdaq.Sensors">sensor</a> that can be used to scale voltage data into
%   sensor data (ex. pressure, temperature, current).
%
%   scale = sdaq.getScaleFun(sensor,calnum) returns a temporary scaling
%   function set to the specified calibration type. Different calibration types 
%   are typically used for different ranges or output units. calnum can be 
%   0, 1 or 2. getScaleFun uses calibration type 0 by default. For more
%   information on calibration types, see README.pdf.
%
%   Once the scaling function has been created, it can be used as a
%   function to scale voltage data. For example, if scale is a scaling
%   function created using one of the above functions:
%       data = scale(voltagedata);
%   data will contain scaled data in physical units. To see the units
%   returned by scale, type:
%       scale.Units
%
%   The function returned by getScaleFun is like any other MATLAB variable
%   with regard to naming and deletion. If the function is lost (for
%   example, if <a href="matlab:help clear">clear</a> is accidentally used), another identical object can be
%   created using getScaleFun.
%
%   Example Usage:
%
%       scale = sdaq.getScaleFun(sdaq.Sensors.Barometer);
%       voltagedata = [1 2 2.5 3.4 3.2];
%       data = scale(voltagedata);
%   
%   Sensor Example:
%
%       % Create a DAT session
%       s = sdaq.createSession; 
%
%       % Add a barometer sensor connected to channel 1
%       sdaq.addSensor(s,1,sdaq.Sensors.Barometer);
%
%       % Get a scaling function
%       barometerscale = sdaq.getScaleFun(sdaq.Sensors.Barometer);
%
%       % Read and scale one sample from the device
%       pressure = barometerscale(s.inputSingleScan);
%
%   See also sdaq.addSensor, sdaq.Sensors

    %   MATLAB Support Package for Vernier SensorDAQ
    %   Version 1.0
    %   Copyright 2011 The MathWorks, Inc.
    
    properties(SetAccess = private)
        SensorType
        CalNumber
    end
    
    properties(SetAccess = private, Dependent)
        Units
    end
    
    properties(Access = private)
        SensorObj
    end
    
    methods
        
        function obj = getScaleFun(sensorobj,calnum)
            validateattributes(sensorobj,{'struct'},{'scalar'});
            if exist('calnum','var')
                validateattributes(calnum,{'numeric'},{'scalar','integer','>=',0,'<=',2});
            else
                calnum = 0;
            end
            
            obj.SensorType = sensorobj.Name;
            obj.SensorObj = sensorobj;
            obj.CalNumber = calnum;
        end
        
        function val = get.Units(obj) %#ok<STOUT>
            evalstr = ['val = obj.SensorObj.Cal' num2str(obj.CalNumber) 'Units;'];
            eval(evalstr);
        end
        
         function val = subsref(obj,a)
             if strcmp(a(1).type,'()')
                 if length(obj) ~= 1
                     error('SENSORDAQ:sensorScalingArray','Arrays of SensorScaling objects are not allowed. Try a cell array instead');
                 end
                 validateattributes(a(1).subs{1},{'numeric'},{'real'});
                 val = obj.scaleSensorData(a(1).subs{1});
             else
                 val = builtin('subsref',obj,a);
             end
         end
        
        function [value units] = scaleSensorData(obj,data)
            validateattributes(data,{'numeric'},{'real'});
            
            
            switch obj.SensorObj.CalEq %define conversion function
                case 'linear'
                    convfunct = @(K,data) K(1)+K(2).*data;
                case 'power'
                    convfunct = @(K,data) K(1)*K(2).^data;
                case 'logarithmic'
                    convfunct = @(K,data) K(1)+K(2).*log(data);
                case 'Steinhart-Hart'
                    convfunct = @(K,data) 1./(K(1)+K(2).*log(data)+K(3).*log(data).^3);
                otherwise
                    error('SENSORDAQ:unsupportedCalEq','Calibration type not recognised.');
            end
                        
            switch obj.CalNumber
                case 0
                    value = convfunct(obj.SensorObj.Cal0Consts,data);
                    units = obj.SensorObj.Cal0Units;
                case 1
                    value = convfunct(obj.SensorObj.Cal1Consts,data);
                    units = obj.SensorObj.Cal1Units;
                case 2
                    value = convfunct(obj.SensorObj.Cal2Consts,data);
                    units = obj.SensorObj.Cal2Units;
                otherwise
                    error('SENSORDAQ:badCalNum','calnum must be 0, 1 or 2');
            end
            
        end
        

    end
    
end

