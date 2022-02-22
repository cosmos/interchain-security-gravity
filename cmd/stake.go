/*
Copyright © 2022 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	binary  *string
	denom   *string
	chainID *string
	granter *string
	grantee *string
	amount  *int
)

// stakeCmd represents the stake command
var stakeCmd = &cobra.Command{
	Use:   "stake",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println(*binary, *denom, *amount)
	},
}

func init() {
	rootCmd.AddCommand(stakeCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// stakeCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// stakeCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
	binary = stakeCmd.Flags().
		String("binary", "simd", "name of binary to run aginst, default is simd")
	granter = stakeCmd.Flags().String("granter", "alice", "granter account name,default is alice")
	grantee = stakeCmd.Flags().String("grantee", "bob", "grantee account name, default is bob")
	denom = stakeCmd.Flags().String("denom", "stake", "denomination of token, default is stake")
	chainID = stakeCmd.Flags().
		String("chain-id", "toka-test", "chain id of the network, default is toka-test")
	amount = stakeCmd.Flags().
		Int("amount", 0, "sets the amount to be staked, default is 0 which means all available tokens")
}
