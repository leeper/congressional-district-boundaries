# Pull or download all of the files from: https://github.com/JeffreyBLewis/congressional-district-boundaries
# This takes a few minutes because of the size and number of files
# Start in the directory containing those files

# load files
f <- list.files(pattern='.geojson')
s <- gsub('.geojson','',f)
u <- gregexpr('_',s)

# get state names
states <- unique(mapply(function(filename, underscores) substring(filename, 1, underscores[length(underscores)-2]-1), s, u))

# create folders for each congress
congresses <- sprintf('congress%03d',1:112)
tmp <- lapply(congresses, dir.create)
rm(tmp)

# for each state, move year files congress-year folders
tmp <- 
lapply(states, function(i) {
    l <- list.files(pattern=i)
    from <- as.numeric(gsub('_to','',regmatches(l,regexpr('[[:digit:]]+_to',l))))
    to <- as.numeric(gsub('to_','',regmatches(l,regexpr('to_[[:digit:]]+',l))))
    mapply(function(numf, numt, whichfile) {
        for(k in numf:numt)
            file.copy(whichfile, paste('./',sprintf('congress%03d',k),'/',i,'.geojson',sep=''))
    }, from, to, l)
})
rm(tmp)

# move original files to a folder
dir.create('./originals')
tmp <- file.copy(f, paste('./originals/',f,sep=''))
file.remove(f)
rm(tmp)

# start git
system('git init')

# move files from folders into main directory and commit
# this is pretty time consuming (~15 minutes)
for(i in 1:length(congresses)){
    statesincong <- list.files(congresses[i])
    file.copy(paste(congresses[i],statesincong,sep='/'), '.', overwrite=TRUE)
    for(j in 1:length(statesincong))
        system(paste('git add ',statesincong[j]))
    system(paste("git commit -m ","'",congresses[i],"'",sep=''))
}
# warnings appear on 005, 059, 067, 071, 076, 077, 082, 096, 097, 101, 102, 111, 112
# This is due to lack of change so there's nothing to commit

# add a git remote
# then just push everything to it (you'll need to open a shell to do it)
# the push is also pretty time consuming (since there's a lot of history)
