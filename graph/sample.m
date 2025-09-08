methods clsGraph

x = -pi:0.1:pi;
y = sin(x);

f1 = clsGraph(1);
f1.plot(x, y);
f1.setLabel('$x$', '$y$');
f1.setLegends({'$\sin x$'});
f1.ax.XLim = [-pi pi];
f1.ax.YLim = [-1.5 1.5];
f1.setLegendsPos('SouthEast');