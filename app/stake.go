package app

import (
	"io/ioutil"
	"path/filepath"
)

// Stake holds all the variables required to execute CompoundStaking
type Stake struct {
	memonic           *string
	binary            *string
	denom             *string
	chainID           *string
	granter           *string
	grantee           *string
	amount            *int
	validators        []string
	validatorFilePath *string
}

// ensure keychain is test

// CompoundStake allows us to withdrawAllRewards for a user
// and redistribute them to a list of validators
func (s *Stake) CompoundStake() error {}

func (s *Stake) getValAddressesFromFile() {
	// get filepath from Stake
	content, err := ioutil.ReadAll(filepath.Abs(*s.validatorFilePath))
	if err != nil {
		return err
	}

}

func (s *Stake) withdrawAllRewards() {}

func (s *Stake) getAddress() {}

func (s *Stake) calculateDelegationAmount() {}

func (s *Stake) execAuthzFromFile() {}

func (s *Stake) genTXJSON() {}
