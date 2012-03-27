function visualize_slabs(model, comps, direction)

% visualizemodel(model)
% Visualize a model.

clf;

if nargin < 3
  direction = 1;
end

rhs = model.rules{model.start}(end).rhs;

filters = {};
for c = 1:length(rhs)
  sym = rhs(c);
  if c > 1
    def_symbol = model.rules{sym}(direction).rhs(1);
    filter_symbol = model.rules{def_symbol}.rhs(1);
  else
    filter_symbol = model.rules{sym}(direction).rhs(1);
  end
  filter_id = model.symbols(filter_symbol).filter;
  w = model.filters(filter_id).w;

  if c == 1
    filters{c} = w;
  else
    filters{c} = cat(1, filters{c-1}, w);
  end
end

if length(model.rules{model.start}(1).rhs) > 1
  O = model.rules{model.start}(1).rhs(2);
  O_def_symbol = model.rules{O}(direction).rhs(1);
  O_filter_symbol = model.rules{O_def_symbol}.rhs(1);
  O_filter_id = model.symbols(O_filter_symbol).filter;
  O_w = model.filters(O_filter_id).w;
else
  O_w = zeros(0, size(X_w, 2), size(X_w, 3));
end
oim = HOGpicture(O_w(:,:,19:27), 20);

nc = length(comps);
h = -inf;
for i = nc:-1:1
  % make picture of root filter
  pad = 2;
  bs = 20;
  %w = foldHOG(filters{comps(i)});
  w = filters{comps(i)}(:,:,19:27);
  scale = max(w(:));
  im = HOGpicture(w, bs);
  if i ~= nc
    im = padarray(im, [2 0], 128, 'post');
    im = cat(1, im, oim);
  else
    im = padarray(im, [2+size(oim,1) 0], 255, 'post');
  end
  h = max(h, size(im,1));
  im = padarray(im, [h-size(im,1) 0], 255, 'post');
  %im = imresize(im, 2);
  %im = padarray(im, [pad pad], 0);
  im = uint8(im * (255/scale));

  % plot parts
  subplot(1,nc,i);
  imagesc(im); 
  colormap gray;
  axis equal;
  axis off;
end

%k = 1;
%for c = comps
%  parts = [];
%  defs = [];
%  anchors = [];
%  for i = 1:c
%    sym = rhs(i);
%    [parts, defs, anchors] = ...
%      get_parts_defs_anchors(model, i, sym, direction, parts, defs, anchors);
%  end
%  if c < length(rhs)
%    root = cat(1, filters{c}, O_w);
%  else 
%    root = filters{c};
%  end
%  visualizecomponent(root, parts, defs, anchors, length(comps), k);
%  k = k + 1;
%end
%
%
%function [parts, defs, anchors] = ...
%  get_parts_defs_anchors(model, ruleind, symbol, direction, parts, defs, anchors)
%
%base_anchor = 2*model.rules{model.start}(ruleind).anchor{ruleind};
%for i = 2:length(model.rules{symbol}(direction).rhs)
%  dsym = model.rules{symbol}(direction).rhs(i);
%  fsym = model.rules{dsym}.rhs(1);
%  fid = model.symbols(fsym).filter;
%  parts(end+1).w = model.filters(fid).w;
%  defs(end+1).w = model.rules{dsym}.def.w;
%  anchors(end+1).w = base_anchor + model.rules{symbol}(direction).anchor{i};
%end
%
%
%
%function visualizecomponent(rootw, parts, defs, anchors, nc, k)
%
%% make picture of root filter
%pad = 2;
%bs = 20;
%w = foldHOG(rootw);
%scale = max(w(:));
%im = HOGpicture(w, bs);
%im = imresize(im, 2);
%im = padarray(im, [pad pad], 0);
%im = uint8(im * (255/scale));
%
%% draw root
%numparts = length(parts);
%if numparts > 0
%  subplot(nc,3,1+3*(k-1));
%else
%  subplot(nc,1,k);
%end
%imagesc(im)
%colormap gray;
%axis equal;
%axis off;
%
%% draw parts and deformation model
%if numparts > 0
%  def_im = zeros(size(im));
%  def_scale = 500;
%  for i = 1:numparts
%    % part filter
%    w = parts(i).w;
%    p = HOGpicture(foldHOG(w), bs);
%    p = padarray(p, [pad pad], 0);
%    p = uint8(p * (255/scale));    
%    % border 
%    p(:,1:2*pad) = 128;
%    p(:,end-2*pad+1:end) = 128;
%    p(1:2*pad,:) = 128;
%    p(end-2*pad+1:end,:) = 128;
%    % paste into root
%    x1 = (anchors(i).w(1))*bs+1;
%    y1 = (anchors(i).w(2))*bs+1;
%    x2 = x1 + size(p, 2)-1;
%    y2 = y1 + size(p, 1)-1;
%    im(y1:y2, x1:x2) = p;
%    
%    % deformation model
%    probex = size(p,2)/2;
%    probey = size(p,1)/2;
%    for y = 2*pad+1:size(p,1)-2*pad
%      for x = 2*pad+1:size(p,2)-2*pad
%        px = ((probex-x)/bs);
%        py = ((probey-y)/bs);
%        v = [px^2; px; py^2; py];
%        p(y, x) = defs(i).w * v * def_scale;
%      end
%    end
%    def_im(y1:y2, x1:x2) = p;
%  end
%  
%  % plot parts
%  subplot(nc,3,2+3*(k-1));
%  imagesc(im); 
%  colormap gray;
%  axis equal;
%  axis off;
%  
%  % plot deformation model
%  subplot(nc,3,3+3*(k-1));
%  imagesc(def_im);
%  colormap gray;
%  axis equal;
%  axis off;
%end
%
set(gcf, 'Color', 'white')