trigger BranchAfterTrg on Account (after insert, after update) {
	if(trigger.isAfter) {
		BranchUtil.processAfterTrg(); 
	}
}