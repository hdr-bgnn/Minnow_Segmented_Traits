# extracting metadata files from download from TU FISH API

# citations for TU FISH API:
# Dom Jebbia, Xiaojun Wang, Yasin Bakis, Henry L. Bart Jr., Jane Greenberg (2022) 
# Toward a Flexible Metadata Pipeline for Fish Specimen Images Proceedings for the 16th Metadata 
# and Semantic Research (MTSR), Springer in Communications in Computer and Information Science 
# arXiv: https://arxiv.org/abs/2211.15472
# Yasin Bakış, Xiaojun Wang, Henry L. Bart Jr., (2021) 
# Evaluating the image quality of digitized biodiversity collections’ specimens 
# 5th Annual Digital Data Conference, Florida Museum of Natural History June 2021
# Yasin Bakış, Xiaojun Wang, Hank Bart (2021) 
# Challenges in Curating 2D Multimedia Data in the Application of Machine Learning in 
# Biodiversity Image Analysis Biodiversity Information Science and Standards 5: e75856 
# doi: 10.3897/biss.5.75856 Received: 27 Sep 2021 | Published: 28 Sep 2021 doi: https://www.doi.org/10.3897/biss.5.75856

# Meghan Balk
# balk@battelleecology.org

#unzip and clean up files
utils::unzip(zipfile = dfs$TU_FISH, 
             exdir = files)

base::file.remove(txtFiles)
base::file.remove(xmlFiles)
