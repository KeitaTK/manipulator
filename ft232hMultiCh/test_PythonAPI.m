clear;
try
    pyList = py.list({1, 2})
    pyList{1}
%     [pyList{:}]
    c = cell(pyList)
    c{1}
    [c{:}]
catch e
%     e
%     disp(e.cause)
    disp(e.identifier);
    disp(e.message);
    disp(e.stack);
end


try
    py.list([1, 2])
    py.list({1, 2})
%     py.list([1; 2])
%     py.list({1; 2})
    py.list(uint8([1, 2]))
%     py.list(uint8([1; 2]))
%     py.list(uint8({1, 2}))
catch e
%     e
%     disp(e.cause)
    disp(e.identifier);
    disp(e.message);
    disp(e.stack);
end
