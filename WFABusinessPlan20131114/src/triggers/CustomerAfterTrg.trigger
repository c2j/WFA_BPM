trigger CustomerAfterTrg on Contact (after update) {
	CustomerUtil.processAfterTrg();

}