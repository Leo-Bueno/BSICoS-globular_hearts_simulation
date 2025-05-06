function voltage = voltage_org(modelo,pathsd,name)

    dir = [pathsd , '\results_H'];

    F1 = importdata([dir,'\tissue\animation.case']);
    L1 = ~cellfun('isempty',strfind(cellstr(F1),'number of steps')); L2 = find(L1);
    numfiles = str2num(F1(L2,17:end)) ; % the number of steps in the animation
    mydata = cell(0, numfiles);

    test_num = numel(num2str(numfiles));
    %numfiles = 10;
%    voltage = zeros(345870, numfiles);
    for k = 1 : numfiles
        if test_num == 1
            myfilename = sprintf('tissue_solution%01d.ens', k-1); % if the numeration has 4 digits
        elseif test_num == 2
            myfilename = sprintf('tissue_solution%02d.ens', k-1); % if the numeration has 4 digits
        elseif test_num == 3
            myfilename = sprintf('tissue_solution%03d.ens', k-1); % if the numeration has 4 digits
        elseif test_num == 4
            myfilename = sprintf('tissue_solution%04d.ens', k-1); % if the numeration has 4 digits
        else
            myfilename = sprintf('tissue_solution%05d.ens', k-1); % if the numeration has 4 digits
        end

      myfilename = [dir,'\tissue\',myfilename];
      mydata{k} = importdata(myfilename,' ',4);
      voltage(:,k) = mydata{1,k}.data(1:end);
      clc;
      fprintf('Orginizing data: %3.2f %% \n', k*100/numfiles);
      drawnow;
    end

    if modelo == 'n'
        ext_file = sprintf('voltage_%s.mat',name);
        dir_volt = [pathsd,'/Pseudo/',ext_file];
        save(dir_volt , 'voltage' , '-v7.3');
     %   save('voltage_o.mat' , 'voltage' , '-v7.3');
    else
        ext_file = sprintf('voltage_g_%s.mat',name);
        dir_volt = [pathsd,'/Pseudo/',ext_file];
        save(dir_volt , 'voltage' , '-v7.3');
    %    save('voltage_g.mat' , 'voltage', '-v7.3');
    end

end