function mha_profiling_plot( cProf )
% MHA_PROFILING_PLOT - plot profiling information
%
% Usage:
% mha_profiling_plot( cProf )
%
% cProf: profiling info (output of mha_profiling_get)
%
% Example:
%
% mhah = struct('host','localhost','port',33337);
% cProf = mha_profiling_get( mhah );
% mha_profiling_plot( cProf );
%
% Author: Giso Grimm
% Date: 4/2009
  ;
  for k=1:size(cProf,1)
    sProf = cProf{k,2};
    ytick = 1:length(sProf.init);
    figure('Name',cProf{k,1},'menubar','none');
    %subplot(3,1,1);
    %barh(ytick,sProf.init);
    %title(['init time (seconds) ',cProf{k,1}],'interpreter','none');
    %set(gca,'YDir','reverse','YTick',ytick,'YTickLabel',sProf.algos,'YLim',[min(ytick)-1,max(ytick)+1]);
    %subplot(3,1,2);
    %barh(ytick,sProf.prepare);
    %title(['prepare time (seconds) ',cProf{k,1}],'interpreter','none');
    %set(gca,'YDir','reverse','YTick',ytick,'YTickLabel',sProf.algos,'YLim',[min(ytick)-1,max(ytick)+1]);
    %subplot(3,1,3);
    %plot([100,100],[min(ytick)-1,max(ytick)+1],'r-','linewidth',2);
    %hold on;
    barh(ytick,sProf.process_load);
    title(cProf{k,1},'interpreter','none');
    set(gca,'YDir','reverse','YTick',ytick,'YTickLabel',sProf.algos,'YLim',[min(ytick)-1,max(ytick)+1]);
    xlabel('process load / percent');
    text(1,1,sprintf('total load = %1.1f%% ',100*sum(sProf.process)/sProf.process_tt),...
	 'Units','normalized','Fontsize',14,'fontweight','bold',...
	 'Color',[1,0,0],'horizontalalign','right','verticalalign','top');
  end