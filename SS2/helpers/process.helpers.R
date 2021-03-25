library(parallel)
library(pagoda2)
library(dplyr)
library(reticulate)
library(grid)
library(gridExtra)
library(dendextend)


#source("_helpers/dynwrap.helpers.R")

load_smartseq2 <- function(struct){
  paths=c()
  for (i in 1:length(struct)){paths=c(paths,paste0(names(struct)[[i]],"/",struct[[i]]))}
  #setwd(paste0("~/NAS/",Project))
  
  #registerDoParallel(cores=ceiling(detectCores()/2))
  outcounts=mclapply(paths, function(p) {
    
    count <- read.table(paste(getwd(),p,"counts.tab",sep="/"),
                        sep="\t",stringsAsFactors = FALSE)
    ercc <- read.table(paste(getwd(),p,"counts-ercc.tab",sep="/"),
                       sep="\t",stringsAsFactors = FALSE)
    
    # for each batch we create a vector in which we repeat the name of the plate as much as there are cells in it
    batch = rep(strsplit(p,"/")[[1]][2],length(count[1,-1]))
    timepoint =rep(strsplit(p,"/")[[1]][1],length(count[1,-1]))
    
    cellnames = count[1,-1]; genenames = count[-1,1]; erccnames = ercc[-1,1]
    count = count[,-1][-1,]; ercc = ercc[,-1][-1,]
    count_and_ercc = rbind(ercc,count)
    
    colnames(count_and_ercc)=paste0(batch,":",cellnames,"_unique.bam")
    rownames(count_and_ercc)=make.unique(c(erccnames,genenames))
    
    
    list(count_and_ercc,erccnames,batch,timepoint)
  },mc.cores = length(paths))
  
  invisible(outcounts)
}

sn <- function(x) { names(x) <- x; return(x); }

t.load.10x.data <- function(matrixPaths) {
  require(parallel)
  require(Matrix)
  mclapply(sn(names(matrixPaths)),function(nam) {
    matrixPath <- matrixPaths[nam];
    # read all count files (*_unique.counts) under a given path
    #cat("loading data from ",matrixPath, " ");
    x <- as(readMM(gzfile(paste(matrixPath,'matrix.mtx.gz',sep='/'))),'dgCMatrix'); # convert to the required sparse matrix representation
    cat(".")
    gs <- read.delim(gzfile(paste(matrixPath,'features.tsv.gz',sep='/')),header=F)
    rownames(x) <- gs$V2
    cat(".")
    gs <- read.delim(gzfile(paste(matrixPath,'barcodes.tsv.gz',sep='/')),header=F)
    colnames(x) <- gs$V1
    cat(".")
    colnames(x) <- paste(nam,colnames(x),sep='_');
    x
  },mc.cores=30)
}

t.load.loom.data <- function(matrixPaths) {
  require(parallel)
  require(Matrix)
  mclapply(sn(names(matrixPaths)),function(nam) {
    matrixPath <- matrixPaths[nam];
    
    
    l=loomR::connect(paste(matrixPath,'counts.loom',sep='/'))
    
    x=Matrix(t(l$matrix[,]),sparse = T)
    rownames(x)=l$row.attrs$symbol[]
    colnames(x)=l$col.attrs$bcs[]
    colnames(x)= paste(nam,colnames(x),sep='_');
    l$close()
    x
  },mc.cores=30)
}

pc.select <- function(p2,plt=F,elbow=T){

  x <- cbind(1:length(p2$misc$PCA$d ), p2$misc$PCA$d)
  line <- x[c(1, nrow(x)),]
  proj <- princurve::project_to_curve(x, line)
  return(which.max(proj$dist_ind))

}

doUMAP <- function(PCA,n_neighbors,min_dist,max_dim=2,seed.use=42){
  require(reticulate)
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
    py_set_seed(seed = seed.use)
  }
  umap_import <- import(module = "umap", delay_load = TRUE)
  umap <- umap_import$UMAP(n_neighbors = as.integer(x = n_neighbors), 
                           n_components = as.integer(x = max_dim), metric = "correlation", 
                           min_dist = min_dist)
  
  umap_output <- umap$fit_transform(as.matrix(x = PCA))
  rownames(umap_output)=rownames(PCA)
  colnames(umap_output)=paste0("UMAP",1:max_dim)
  
  return(umap_output)
}



doUMAP_GPU <- function(PCA,n_neighbors,min_dist,max_dim=2,seed.use=42){
  require(reticulate)
  if (!is.null(x = seed.use)) {
    set.seed(seed = seed.use)
    py_set_seed(seed = seed.use)
  }
  umap_import <- import(module = "umap", delay_load = TRUE)
  umap <- umap_import$UMAP(n_neighbors = as.integer(x = n_neighbors), 
                           n_components = as.integer(x = max_dim), 
                           min_dist = min_dist)
  
  umap_output <- umap$fit_transform(as.matrix(x = PCA))
  rownames(umap_output)=rownames(PCA)
  colnames(umap_output)=paste0("UMAP",1:max_dim)
  
  return(umap_output)
}


doTrimap <- function(PCA,n_in=10,n_out=5,n_rand=5,dist="angular",wadj=500,n_it=400,max_dim=2,seed.use=42){
  require(reticulate)
  trimap_import <- import(module = "trimap", delay_load = TRUE)
  trimap <- trimap_import$TRIMAP(apply_pca=FALSE,
                                 n_inliers=as.integer(x = n_in),
                                 n_outliers=as.integer(x = n_out),
                                 n_random=as.integer(x = n_rand),
                                 distance=dist,
                                 weight_adj=wadj,
                                 n_iters=as.integer(n_it))
  
  trimap_output <- trimap$fit_transform(as.matrix(x = PCA))
  rownames(trimap_output)=rownames(PCA)
  colnames(trimap_output)=paste0("trimap",1:max_dim)
  
  return(trimap_output)
}

doPalantir <- function(PCA,n_neighbors,min_dist,diff_knn=30,n_eig=NULL,seed.use=42){
  library(reticulate)
  
  palantir=import("palantir")
  pd=import("pandas")
  umap=import("umap")
  
  pca_py=pd$DataFrame(r_to_py(PCA))
  dm_res=palantir$utils$run_diffusion_maps(pca_py,knn=as.integer(diff_knn))
  if (!is.null(n_eig)){
    ms_data = palantir$utils$determine_multiscale_space(dm_res,n_eigs=as.integer(n_eig))
  } else {
    ms_data = palantir$utils$determine_multiscale_space(dm_res)
  }
  
  
  ms_data=as.matrix(ms_data);
  rownames(ms_data)=rownames(PCA);colnames(ms_data)=paste0("Dim",1:ncol(ms_data))
  
  
  set.seed(seed = seed.use)
  py_set_seed(seed = seed.use)
  fit=umap$UMAP(n_neighbors=as.integer(n_neighbors),min_dist=min_dist)
  u=fit$fit_transform(ms_data)
  
  rownames(u)=rownames(ms_data)
  return(list(ms_data=ms_data,umap=u))
}



p2.wrapper <- function(counts,n_neighbors=30,min_dist=.3,npcs=200,pcsel=T,...) {
  rownames(counts) <- make.unique(rownames(counts))
  p2 <- Pagoda2$new(counts,n.cores=parallel::detectCores()/2,...)
  p2$adjustVariance(plot=T,gam.k=10)
  p2$calculatePcaReduction(nPcs=npcs,n.odgenes=NULL,maxit=1000)
  
  if (pcsel){
    opt=pc.select(p2);cat(paste0(opt," PCs retained\n"))
  } else {
    opt=npcs
  }
  
  
  p2$reductions$PCA=p2$reductions$PCA[,1:opt]
  cat("Computing UMAP... ")
  p2$embeddings$PCA$UMAP=doUMAP(p2$reductions$PCA,n_neighbors,min_dist)
  
  cat("done\n")
  p2$makeKnnGraph(k=40,type='PCA',center=T,distance='cosine');
  p2$getKnnClusters(method=conos::leiden.community,type='PCA',name = "leiden")
  invisible(p2)
}

p2w.wrapper <- function(p2,app.title = 'Pagoda2', extraWebMetadata = NULL, n.cores = 4) {
  cat('Calculating hdea...\n')
  hdea <- p2$getHierarchicalDiffExpressionAspects(type='PCA',clusterName='leiden',z.threshold=3, n.cores = n.cores)
  metadata.forweb <- list();
  metadata.forweb$leiden <- p2.metadata.from.factor(p2$clusters$PCA$leiden,displayname='leiden')
  metadata.forweb <- c(metadata.forweb, extraWebMetadata)
  genesets <- hierDiffToGenesets(hdea)
  appmetadata = list(apptitle=app.title)
  cat('Making KNN graph...\n')
  p2$makeGeneKnnGraph(n.cores=n.cores)
  make.p2.app(p2, additionalMetadata = metadata.forweb, geneSets = genesets, dendrogramCellGroups = p2$clusters$PCA$leiden, show.clusters=F, appmetadata = appmetadata)
}


