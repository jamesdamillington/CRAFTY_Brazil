/**
 * This file is part of
 * 
 * CRAFTY - Competition for Resources between Agent Functional TYpes
 *
 * Copyright (C) 2014 School of GeoScience, University of Edinburgh, Edinburgh, UK
 * 
 * CRAFTY is free software: You can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software 
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *  
 * CRAFTY is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * School of Geoscience, University of Edinburgh, Edinburgh, UK
 */
package org.volante.abm.serialization;

import javax.swing.BoxLayout;
import javax.swing.JFrame;

import mpi.MPI;

import org.apache.commons.cli.BasicParser;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.log4j.Logger;
import org.volante.abm.param.RandomPa;
import org.volante.abm.schedule.RunInfo;
import org.volante.abm.schedule.ScheduleThread;
import org.volante.abm.visualisation.ScheduleControls;
import org.volante.abm.visualisation.TimeDisplay;

import de.cesr.more.basic.MManager;
import de.cesr.more.util.MVersionInfo;
import de.cesr.parma.core.PmParameterManager;


public class ModelRunner
{

	static final String		CONFIG_LOGGER_NAME	= "crafty.config";

	/**
	 * Logger
	 */
	static private Logger logger = Logger.getLogger(ModelRunner.class);
	static private Logger	clogger				= Logger.getLogger(CONFIG_LOGGER_NAME);

	public static void clog(String property, String value) {
		clogger.info(property + ": \t" + value);
	}

	public static Logger getConfigLogger() {
		return clogger;
	}

	public static void main( String[] args ) throws Exception
	{
		logger.info("Start CRAFTY CoBRA");
		
		String[] realArgs = null;

		try {
			Class.forName("mpi.MPI");
			realArgs = MPI.Init(args);

		} catch (NoClassDefFoundError e) {
			logger.error("No MPI in classpath (this message can be ignored if not running in parallel)!");
			realArgs = args;
		} catch (ClassNotFoundException e) {
			logger.error("No MPI in classpath (this message can be ignored if not running in parallel)!");
			realArgs = args;

		} catch (UnsatisfiedLinkError e) {
			logger.error(
			        "MPI is in classpath but not linked to shared libraries correctly (this message can be ignored if not running in parallel)!");
			realArgs = args;
		}

		CommandLineParser parser = new BasicParser();
		CommandLine cmd = parser.parse(manageOptions(), realArgs);
		if (cmd.hasOption('h')) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("CRAFTY", manageOptions());
			System.exit(0);
		}

		boolean interactive = cmd.hasOption("i");
		
		String filename = cmd.hasOption("f") ? cmd.getOptionValue('f') : "xml/test-scenario.xml";
		String directory = cmd.hasOption("d") ? cmd.getOptionValue('d')
				: "data";

		int start = cmd.hasOption("s") ? Integer.parseInt(cmd.getOptionValue('s'))
				: Integer.MIN_VALUE;
		int end = cmd.hasOption("e") ? Integer.parseInt(cmd.getOptionValue('e'))
				: Integer.MIN_VALUE;

		int numRuns = cmd.hasOption("n") ? Integer.parseInt(cmd.getOptionValue('n')) : 1;
		int startRun = cmd.hasOption("sr") ? Integer.parseInt(cmd.getOptionValue("sr")) : 0;

		int numOfRandVariation = cmd.hasOption("r") ? Integer.parseInt(cmd.getOptionValue('r')) : 1;

		clog("Scenario-File", filename);
		clog("DataDir", directory);
		clog("StartTick", "" + (start == Integer.MIN_VALUE ? "<ScenarioFile>" : start));
		clog("EndTick", "" + (end == Integer.MIN_VALUE ? "<ScenarioFile>" : end));

		clog("CRAFY_CoBRA Revision", CVersionInfo.REVISION_NUMBER);
		clog("CRAFY_CoBRA BuildDate", CVersionInfo.TIMESTAMP);
		
		clog("MoRe Revision", MVersionInfo.revisionNumber);
		clog("MoRe BuildDate", MVersionInfo.timeStamp);

		if (end < start) {
			logger.error("End tick must not be larger than start tick!");
			System.exit(0);
		}

		if (startRun > numRuns) {
			logger.error("StartRun must not be larger than number of runs!");
			System.exit(0);
		}

		for (int i = startRun; i < numRuns; i++) {//for each run
			for (int j = 0; j < numOfRandVariation; j++) {//for each randomvariation with default = 1 (command option)
				int randomSeed = cmd.hasOption('o') ? (j + Integer
						.parseInt(cmd.getOptionValue('o')))//add randomseedoffset (command option)
						: (int) System
								.currentTimeMillis();//otherwise random
				// Worry about random seeds here...
				RunInfo rInfo = new RunInfo();
				rInfo.setNumRuns(numRuns);
				rInfo.setNumRandomVariations(numOfRandVariation);
				rInfo.setCurrentRun(i);
				rInfo.setCurrentRandomSeed(randomSeed);//update rInfo with number of runs, runvariation, currentrun and 
				//randomseed (cmd options for the most part)

				ABMPersister.getInstance().setBaseDir(directory);//if first run create new instance of persister. 
				//in either case set base dit to data or other user spec
				if (cmd.hasOption("se") ? BatchRunParser.parseInt(cmd.getOptionValue("se"), rInfo) == 1
						: true) {//if se option included more info printed to trace (see below)
					clog("CurrentRun", "" + i);
					clog("TotalRuns", "" + numRuns);
					clog("CurrentRandomSeed", "" + randomSeed);
					clog("TotalRandomSeeds", "" + numOfRandVariation);

					PmParameterManager.getInstance(null).setParam(RandomPa.RANDOM_SEED, randomSeed);// UNKNOWN 

					doRun(filename, start, end, rInfo, interactive);//do the run passing the Scenario.xml
				}
			}
		}

		try {
			Class.forName("mpi.MPI");
			MPI.Finalize();
		} catch (ClassNotFoundException e) {
			logger.info("Error during MPI finilization. No MPI in classpath!");
//			e.printStackTrace();
		} catch (NoClassDefFoundError ncde) {
			logger.info("Error during MPI finilization. No MPI class linked!");
//			ncde.printStackTrace();
		} catch (Exception exception) {
			logger.info("Error during MPI finilization: " + exception.getMessage());
			exception.printStackTrace();
		}
	}

	public static void doRun(String filename, int start,
			int end, RunInfo rInfo, boolean interactive) throws Exception
	{
		ScenarioLoader loader = setupRun(filename, start, end, rInfo);
		if (interactive) {
			interactiveRun(loader);
		} else {
			noninteractiveRun(loader, start == Integer.MIN_VALUE ? loader.startTick : start,
					end == Integer.MIN_VALUE ? loader.endTick : end);
			finalActions(rInfo);
		}
	}

	public static void noninteractiveRun( ScenarioLoader loader, int start, int end )
	{
		logger.info(String.format("Running from %s to %s\n",
				(start == Integer.MIN_VALUE ? "<ScenarioFile>" : start + ""),
				(end == Integer.MIN_VALUE ? "<ScenarioFile>" : end + "")));

		if (end != Integer.MIN_VALUE) {
			if (start != Integer.MIN_VALUE) {
				loader.schedule.runFromTo(start, end);
			} else {
				loader.schedule.runUntil(end);
				loader.schedule.finish();
			}
		} else {
			loader.schedule.run();
			loader.schedule.finish();
		}
	}

	public static void interactiveRun(final ScenarioLoader loader)
	{
		logger.info("Setting up interactive run");
		ScheduleThread thread = new ScheduleThread( loader.schedule );
		thread.start();
		JFrame controls = new JFrame();
		TimeDisplay td = new TimeDisplay( loader.schedule );
		ScheduleControls sc = new ScheduleControls( loader.schedule );
		controls.getContentPane().setLayout( new BoxLayout( controls.getContentPane(), BoxLayout.Y_AXIS ) );
		controls.add( td );
		controls.add( sc );
		controls.pack();
		controls.setDefaultCloseOperation( JFrame.EXIT_ON_CLOSE );
		controls.addWindowListener(new java.awt.event.WindowAdapter() {
		    @Override
		    public void windowClosing(java.awt.event.WindowEvent windowEvent) {
				ModelRunner.finalActions(loader.info);
			}
		});
		controls.setVisible( true );
	}

	public static ScenarioLoader setupRun(String filename,
			int start, int end, RunInfo rInfo) throws Exception
	{
		// TODO override persister method
		System.out.println(ScenarioLoader.class);
		ScenarioLoader loader = ABMPersister.getInstance().readXML(ScenarioLoader.class, filename,
				null);
		
		loader.setRunID(rInfo.getCurrentRun() + "-" + rInfo.getCurrentRandomSeed());
		loader.initialise(rInfo);
		loader.schedule.setRegions(loader.regions);
		
		return loader;
	}

	@SuppressWarnings("static-access")
	protected static Options manageOptions() {
		Options options = new Options();

		options.addOption(OptionBuilder.withDescription("Display usage")
				.withLongOpt("help")
				.isRequired(false)
				.create("h"));

		options.addOption(OptionBuilder.withDescription("Interactive mode?")
				.withLongOpt("interactive")
				.isRequired(false)
				.create("i"));

		options.addOption(OptionBuilder.withArgName("dataDirectory")
				.hasArg()
				.withDescription("Location of data directory")
				.withLongOpt("directory")
				.isRequired(false)
				.create("d"));

		options.addOption(OptionBuilder.withArgName("scenarioFilename")
				.hasArg()
				.withDescription("Location and name of scenario file relative to directory")
				.withLongOpt("filename")
				.isRequired(false)
				.create("f"));

		options.addOption(OptionBuilder.withArgName( "startTick" )
				.hasArg()
				.withDescription("Start tick of simulation")
				.withType(Integer.class)
				.withLongOpt("start")
				.isRequired(false)
				.create("s"));

		options.addOption(OptionBuilder.withArgName("endTick")
				.hasArg()
				.withDescription("End tick of simulation")
				.withType(Integer.class)
				.withLongOpt("end")
				.isRequired(false)
				.create("e"));

		options.addOption(OptionBuilder.withArgName("numOfRuns")
				.hasArg()
				.withDescription("Number of runs with distinct configuration")
				.withType(Integer.class)
				.withLongOpt("runs")
				.isRequired(false)
				.create("n"));

		options.addOption(OptionBuilder.withArgName("startRun")
				.hasArg()
				.withDescription("Number of run to start with (first one is 0)")
				.withType(Integer.class)
				.withLongOpt("startRun")
				.isRequired(false)
				.create("sr"));

		options.addOption(OptionBuilder.withArgName("numOfRandVariation")
				.hasArg()
				.withDescription("Number of runs of each configuration with distinct random seed)")
				.withType(Integer.class)
				.withLongOpt("randomVariations")
				.isRequired(false)
				.create("r"));

		options.addOption(OptionBuilder.withArgName("offset")
				.hasArg()
				.withDescription("Random seed offset")
				.withType(Integer.class)
				.withLongOpt("randomseedoffset")
				.isRequired(false)
				.create("o"));

		options.addOption(OptionBuilder.withArgName("subset")
				.hasArg()
				.withDescription("Expression that is checked to return 1 for each started run.")
				.withType(Integer.class)
				.withLongOpt("subsetExpression")
				.isRequired(false)
				.create("se"));
		return options;
	}

	protected static void finalActions(RunInfo rInfo) {
		rInfo.getOutputs().removeClosingOutputThreads();
		PmParameterManager.reset();
		MManager.reset();
	}
}
