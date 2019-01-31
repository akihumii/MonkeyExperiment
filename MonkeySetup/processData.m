function processData(src,data,fid,hObject)

nsamp = size(data.Data,1);
numchans = size(data.Data,2);
handles=guidata(hObject);
for i=1:nsamp
    fprintf(fid,'%6.4f ',data.TimeStamps(i));
    for j=1:numchans
        fprintf(fid,'%2.4f ',data.Data(i,j));
    end
    fprintf(fid,'\n');
end

if (handles.doPlot)
    
    % if first time, add the legend and create the plot
    % graphics object
    if(handles.newplot)
        legend(handles.axes1,handles.sel_legend);
        handles.newplot=false;
        
        handles.hPlot = plot(NaN,NaN);
        
        guidata(hObject,handles);
    end
    
    % update the x and y data
    xdata = [get(handles.hPlot,'XData') data.TimeStamps];
    ydata = [get(handles.hPlot,'YData') data.Data(:,handles.sel_index)];
    set(handles.hPlot,'XData',xdata,'YData',ydata);
end