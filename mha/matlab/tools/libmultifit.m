function sLib = libmultifit()
% LIBMULTIFIT - function handle library
%
% Usage:
% libmultifit()
%
% Help to function "fun" can be accessed by calling
% multifit.help.fun()
%

% This file was generated by "bake_mlib multifit".
% Do not edit! Edit sources multifit_*.m instead.
%
% Date: 09-Jun-2017 16:16:03
sLib = struct;
sLib.apply_noisegate = @multifit_apply_noisegate;
sLib.help.apply_noisegate = @help_apply_noisegate;
sLib.firstfit = @multifit_firstfit;
sLib.help.firstfit = @help_firstfit;
sLib.fitall_flat = @multifit_fitall_flat;
sLib.help.fitall_flat = @help_fitall_flat;
sLib.fitall_flat40 = @multifit_fitall_flat40;
sLib.help.fitall_flat40 = @help_fitall_flat40;
sLib.gainrule_doc = @multifit_gainrule_doc;
sLib.help.gainrule_doc = @help_gainrule_doc;
sLib.list_gainrules = @multifit_list_gainrules;
sLib.help.list_gainrules = @help_list_gainrules;
sLib.query = @multifit_query;
sLib.help.query = @help_query;
sLib.targetgain = @multifit_targetgain;
sLib.help.targetgain = @help_targetgain;
sLib.upload = @multifit_upload;
sLib.help.upload = @help_upload;
sLib.uploadallfirstfit = @multifit_uploadallfirstfit;
sLib.help.uploadallfirstfit = @help_uploadallfirstfit;
sLib.validate_fits = @multifit_validate_fits;
sLib.help.validate_fits = @help_validate_fits;
sLib.verify = @multifit_verify;
sLib.help.verify = @help_verify;
assignin('caller','multifit',sLib);


function sGt = multifit_apply_noisegate( sGt )
  if isfield( sGt, 'noisegate' )
    for ch='lr'
      for kf=1:length(sGt.frequencies)
	Gain_Noisegate = interp1(sGt.levels,sGt.(ch)(:,kf), ...
				 sGt.noisegate.(ch).level(kf),'linear','extrap');
	idx = find(sGt.levels<sGt.noisegate.(ch).level(kf));
	sGt.(ch)(idx,kf) = (sGt.levels(idx)-sGt.noisegate.(ch).level(kf))* ...
	    sGt.noisegate.(ch).slope(kf) + Gain_Noisegate;
      end
    end
  end


function help_apply_noisegate
disp([' APPLY_NOISEGATE - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  sGt = multifit.apply_noisegate( sGt );',char(10),'']);


function sPlug = multifit_firstfit( sPlug, sGainrule, sAud, sSide )
% fill gaintable structure
%
% sPlug     : plugin handle
% sGainrule : name of gainrule
% sAud      : auditory profile
% sSide     : side to fit (l, r, lr, rl)
  switch sSide
   case {'l','r','lr','rl'}
   otherwise
    error(['invalid side "',sSide,'"']);
  end
  sPlug.audprof = sAud;
  % update the fitting model (i.e., hearing aid model):
  %sPlug.fitmodel = feval(sPlug.mha2fitmodel,sPlug.plugincfg);
  sPlug.fitmodel.side = sSide;
  % apply gain rule and create gain table:
  sPlug.gaintable = feval(['gainrule_',sGainrule],sAud,sPlug.fitmodel);
  sPlug.gaintable = merge_structs(sPlug.fitmodel,sPlug.gaintable);
  sPlug.gainrule = sGainrule;


function help_firstfit
disp([' FIRSTFIT - fill gaintable structure',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  sPlug = multifit.firstfit( sPlug, sGainrule, sAud, sSide );',char(10),'',char(10),'',char(10),' sPlug     : plugin handle',char(10),' sGainrule : name of gainrule',char(10),' sAud      : auditory profile',char(10),' sSide     : side to fit (l, r, lr, rl)',char(10),'']);


function csPlugs = multifit_fitall_flat( mha, sGainrule, HTL)
  cdb = libclientdb();
  sAud = cdb.flat_aud( HTL );
  csPlugs = multifit_uploadallfirstfit( mha, sGainrule, sAud, 'lr' );


function help_fitall_flat
disp([' FITALL_FLAT - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  csPlugs = multifit.fitall_flat( mha, sGainrule, HTL);',char(10),'']);


function csPlugs = multifit_fitall_flat40( mha, sGainrule )
  csPlugs = multifit_fitall_flat( mha, sGainrule, 40 );


function help_fitall_flat40
disp([' FITALL_FLAT40 - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  csPlugs = multifit.fitall_flat40( mha, sGainrule );',char(10),'']);


function csHelp = multifit_gainrule_doc
  csRules = multifit_list_gainrules;
  csHelp = [csRules,csRules];
  for k=1:size(csRules,1)
    csHelp{k,2} = help(['gainrule_',csRules{k}]);
  end


function help_gainrule_doc
disp([' GAINRULE_DOC - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  csHelp = multifit.gainrule_doc();',char(10),'']);


function csRules = multifit_list_gainrules
  [pathstr,name,ext] = fileparts(mfilename('fullpath'));
  d1 = dir([pathstr,filesep,'gainrule_*.m']);
  d2 = dir([pathstr,filesep,'gainrule_*.',mexext]);
  d = [d1(:);d2(:)];
  csRules = cell(length(d),1);
  for k=1:length(d)
    [pathstr,name,ext] = fileparts(d(k).name);
    csRules{k} = name(10:end);
  end


function help_list_gainrules
disp([' LIST_GAINRULES - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  csRules = multifit.list_gainrules();',char(10),'']);


function csPlugs = multifit_query( mha )
  global mha_basic_cfg;
  mha_get_basic_cfg_network( mha );
  csPlugs = {};
  lfa = libfitadaptor();
  for kPlug=1:size(mha_basic_cfg.all_id_plugs,1)
    sAddr = mha_basic_cfg.all_id_plugs{kPlug,1};
    sPlug = mha_basic_cfg.all_id_plugs{kPlug,2};
    sMultifitRule1 = [sPlug,'_mha2fitmodel'];
    sMultifitRule2 = [sPlug,'_gt2mha'];
    if isfield(lfa,sMultifitRule1) && isfield(lfa,sMultifitRule2)
      sCfg = struct;
      sCfg.addr = sAddr;
      sCfg.plugin = sPlug;
      sCfg.plugincfg = mha_get(mha,sAddr);
      sCfg.mha2fitmodel = lfa.(sMultifitRule1);
      sCfg.gaintable2mha = func2str(lfa.(sMultifitRule2));
      sCfg.fitmodel = sCfg.mha2fitmodel(sCfg.plugincfg);
      sCfg.mha2fitmodel = func2str(sCfg.mha2fitmodel);
      csPlugs{end+1} = sCfg;
    end
  end


function help_query
disp([' QUERY - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  csPlugs = multifit.query( mha );',char(10),'']);


function sTarget = multifit_targetgain( sFit, vLevel )
  sTarget = struct;
  [vLTASS, vF] = private_LTASS_combined();
  sTarget.levels = vLevel;
  sTarget.f = vF;
  sTarget.inlevel = repmat(vLTASS,[length(vLevel),1])+ ...
      repmat(vLevel(:),[1,length(vLTASS)]);
  sGt = multifit_apply_noisegate( sFit.gaintable );
  fGt = sGt.frequencies(:)';
  fGt = [min(fGt(1)/2,min(vF)),fGt,max(2*fGt(end),max(vF))];
  lGt = sGt.levels(:)';
  lGt = [lGt(1)-100,lGt,lGt(end)+100];
  for ch='lr'
    Gt = sGt.(ch);
    Gt = [Gt(:,1),Gt,Gt(:,end)];
    xGt = zeros(2,size(Gt,2));
    for k=1:length(fGt)
      xGt(1,k) = interp1(lGt(2:end-1),Gt(:,k),lGt(1),'linear','extrap');
      xGt(2,k) = interp1(lGt(2:end-1),Gt(:,k),lGt(end),'linear','extrap');
    end
    Gt = [xGt(1,:);Gt;xGt(2,:)];
    sTarget.(ch).outlevel = zeros(size(sTarget.inlevel));
    for k=1:size(sTarget.inlevel,1)
      sTarget.(ch).outlevel(k,:) = ...
	  interp2(fGt,lGt,Gt,vF,sTarget.inlevel(k,:),'linear')+sTarget.inlevel(k,:);
    end
  end

function [vLTASS_combined, vF] = private_LTASS_combined
  vF = [63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, ...
	1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, ...
	10000, 12500, 16000];
  vLTASS_combined = [38.6, 43.5, 54.4, 57.7, 56.8, 60.2, 60.3, 59.0, ...
		     62.1, 62.1, 60.5, 56.8, 53.7, 53.0, 52.0, 48.7, ...
		     48.1, 46.8, 45.6, 44.5, 44.3, 43.7, 43.4, 41.3, 40.7]-70;
  

function help_targetgain
disp([' TARGETGAIN - ',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  sTarget = multifit.targetgain( sFit, vLevel );',char(10),'']);


function sGt = multifit_upload( sFit, mha )

  sGt = sFit.gaintable;
  if isfield(sFit,'finetuning')
    libfinetuning();
    sGt = finetuning.apply(sFit.finetuning,sGt);
  end
  % create noisegate:
  sGt = multifit_apply_noisegate( sGt );
  sGt.fit = sFit;
  % create MHA configuration and upload:
  
  % TODO: a temporary hack -----------------------
  % finds the function_handle in the library by value
  lfau = libfitadaptor();
  fields = fieldnames(lfau);
  for i = 1:numel(fields)
    if ~isstruct(lfau.(fields{i}))
      if isequal(sFit.gaintable2mha,func2str(lfau.(fields{i})))
        sFit.gaintable2mha = lfau.(fields{i});
        break;
      end
     end 
  end
  %------------------------------------------------
  mhacfg = sFit.gaintable2mha(sGt,sFit.plugincfg);
  sFit.gaintable2mha = func2str(sFit.gaintable2mha);
  mha_set(mha,sFit.addr,mhacfg);



function help_upload
disp([' UPLOAD - create noisegate:',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  sGt = multifit.upload( sFit, mha );',char(10),'',char(10),'']);


function csPlugs = multifit_uploadallfirstfit( mha, sGainrule, sAud, sSide )
% upload First Fit to all fittable plugins
%
% mha       : MHA handle
% sGainrule : name of gain prescription rule, or empty to
%             autodetect by plugin name
% sAud      : auditory profile
% sSide     : side to fit (l, r, lr, rl)
  
  sGRuleLocal = sGainrule;
  csPlugs = multifit_query(mha);
  for k=1:length(csPlugs)
    sFit = csPlugs{k};
    if isempty( sGainrule )
      sGRuleLocal = sFit.addr;
      sGRuleLocal(1:max(find(sGRuleLocal=='.'))) = [];
      if ~exist(['gainrule_',sGRuleLocal])
	msg = ['Gainrule ''',sGRuleLocal,''' does not exist.'];
	errordlg(msg);
	error(msg);
      end
    end
    sFit = multifit_firstfit( sFit, sGRuleLocal, sAud, sSide );
    multifit_upload( sFit, mha );
    csPlugs{k} = sFit;
  end


function help_uploadallfirstfit
disp([' UPLOADALLFIRSTFIT - upload First Fit to all fittable plugins',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  csPlugs = multifit.uploadallfirstfit( mha, sGainrule, sAud, sSide );',char(10),'',char(10),'',char(10),' mha       : MHA handle',char(10),' sGainrule : name of gain prescription rule, or empty to',char(10),'             autodetect by plugin name',char(10),' sAud      : auditory profile',char(10),' sSide     : side to fit (l, r, lr, rl)',char(10),'']);


function vValid = multifit_validate_fits( csFits, sFit, mha )
  lfa=libfitadaptor();
  sMHACfg = mha_get(mha,sFit.addr);
  vValid = ones(size(csFits));
  for k=1:length(csFits)
    try
      sFitL = csFits{k};
      % This is ugly and relies on consinstent naming in libfitadaptor(): remove
      % 'fitadaptor_' to get the function you want to call
      % This hack replaces to use of function handles which cannot be saved by octave 
      sCurrentFitmodel = merge_structs(eval(['lfa.' sFitL.mha2fitmodel(12:end) '(sMHACfg)']),sFitL.fitmodel);
      % This is the old solution which needs a function handle
      % sCurrentFitmodel = merge_structs(sFitL.mha2fitmodel(sMHACfg),sFitL.fitmodel);
      if ~isequal(sCurrentFitmodel,sFitL.fitmodel)
	vValid(k) = 0;
      end
    catch
      vValid(k) = 0;
    end
  end


function help_validate_fits
disp([' VALIDATE_FITS - This is ugly and relies on consinstent naming in libfitadaptor(): remove',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  vValid = multifit.validate_fits( csFits, sFit, mha );',char(10),'',char(10),' ''fitadaptor_'' to get the function you want to call',char(10),' This hack replaces to use of function handles which cannot be saved by octave ',char(10),'']);


function sFit = multifit_verify( sFit, mha )
  ;
  % verify that current plugin setting is compatible with fit model:
  sCurrentFitmodel = merge_structs(sFit.mha2fitmodel(mha_get(mha,sFit.addr)),sFit.fitmodel);
  if ~isequal(sCurrentFitmodel,sFit.fitmodel)
    error('The current plugin settings are incompatible with the fit.');
  end


function help_verify
disp([' VERIFY - that current plugin setting is compatible with fit model:',char(10),'',char(10),' Usage:',char(10),'  multifit = libmultifit();',char(10),'  sFit = multifit.verify( sFit, mha );',char(10),'',char(10),'']);


