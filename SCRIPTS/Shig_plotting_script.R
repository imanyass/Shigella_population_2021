#barplot
library(ggplot2)
library(readr)

Shig_tab1 <- read.delim("Shig_routineSDSB.txt",sep = "\t", dec = ",")
View(Shig_tab1)


#### Shigella dysenteriae & Shigella boydii 

Shig_tab1$Type <- factor(Shig_tab1$Type,levels=c("SB1","SB2","SB4","SB5","SB8","SB9","SB10","SB11","SB14","SB18","SB19","SB20","SB22","SD2","SD3","SD4","SD9","SD12","SD16","SD17","SDprov"))
Shig_tab1$QUAL <- factor(Shig_tab1$QUAL,levels=c("None","Incorrect","Uncertain","Correct"))
Shig_tab1$Typer <- factor(Shig_tab1$Typer,levels=c("SeroPred","ShigaTyper","ShigEiFinder_Reads","ShigEiFinder_Fasta"))
p1<-ggplot(data=Shig_tab1, aes(y=Score, x=Typer, fill=QUAL))+ geom_bar(stat="identity", color=NA, width=.7, position = position_stack(.9)) +scale_y_continuous(expand=c(0,0)) +scale_x_discrete(expand=c(.2,0), labels=c("SeroPred" = "E", "ShigaTyper" = "T","ShigEiFinder_Reads" = "R", "ShigEiFinder_Fasta" = "F"))#+ geom_text(aes(label=Score), position = position_stack(vjust= 0.5),color = "white", size = 1)
SDSB_graph <- p1+ scale_color_grey()  + theme_classic() + facet_grid(.~ Type)  + theme( axis.line.x = element_line(color = NA)) + theme( axis.line.y = element_line(color = "black"))+theme(axis.title.x=element_blank(),axis.text.x=element_text(size=4, angle =0),axis.ticks.x=element_blank()) + theme(axis.text.y= element_text(size=8))+  theme(strip.text.x = element_text(angle = 0, size = 6),panel.border = element_rect(color = NA, fill = NA, size = 1),  strip.background = element_rect(color = NA, size = 1))+ scale_fill_manual(values=c("lightgrey",'#323935','#37abc8ff','#15D173'))
library(gridExtra)
library(cowplot)
SDSB_graph


#### Shigella flexneri &Shigella sonnei
Shig_tab2 <- read.delim("Shig_routineSFSon.txt",sep = "\t", dec = ",")
View(Shig_tab2)

Shig_tab2$Type <- factor(Shig_tab2$Type,levels=c("Son","SF1-5","SF1a","SF1b","SF1c","SF2a","SF2b","SF3a","SF3b","SF4a","SF4av","SF7b","SFX","SFXv","SFY","SFYv","SF6"))
Shig_tab2$QUAL <- factor(Shig_tab2$QUAL,levels=c("None","Incorrect","Uncertain","Correct"))
Shig_tab2$Typer <- factor(Shig_tab2$Typer,levels=c("SeroPred","ShigaTyper","ShigEiFinder_Reads","ShigEiFinder_Fasta"))
p2<-ggplot(data=Shig_tab2, aes(y=Score, x=Typer, fill=QUAL))+ geom_bar(stat="identity", color=NA, width=.7, position = position_stack(.9)) +scale_y_continuous(expand=c(0,0)) +scale_x_discrete(expand=c(.2,0), labels=c("SeroPred" = "E", "ShigaTyper" = "T","ShigEiFinder_Reads" = "R", "ShigEiFinder_Fasta" = "F"))#+ geom_text(aes(label=Score), position = position_stack(vjust= 0.5),color = "white", size = 1)
SFSon_graph <- p2+ scale_color_grey()  + theme_classic() + facet_grid(.~ Type)  + theme( axis.line.x = element_line(color = NA)) + theme( axis.line.y = element_line(color = "black"))+theme(axis.title.x=element_blank(),axis.text.x=element_text(size=4, angle =0),axis.ticks.x=element_blank()) + theme(axis.text.y= element_text(size=8))+  theme(strip.text.x = element_text(angle = 0, size = 6),panel.border = element_rect(color = NA, fill = NA, size = 1),  strip.background = element_rect(color = NA, size = 1))+ scale_fill_manual(values=c("lightgrey",'#323935','#37abc8ff','#15D173'))
library(gridExtra)
library(cowplot)
SFSon_graph

plot_grid(SB_graph, SB_graph2, labels=c(), ncol = 1, nrow = 2)


