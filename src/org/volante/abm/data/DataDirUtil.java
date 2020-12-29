package org.volante.abm.data;

import java.io.File;
import java.io.FileNotFoundException;

import org.apache.log4j.Logger;

/**
 * Utility class that gets the path to the CRAFTY Brazil project's {@code data/}
 * directory.
 */
public final class DataDirUtil {

	private final static Logger logger = Logger.getLogger(DataDirUtil.class);

	private DataDirUtil() {
	} // This utility class cannot be instantiated

	/**
	 * Get the path to the CRAFTY Brazil project's data directory.
	 *
	 * <p>
	 * Returns {@code $CRAFTY_BRAZIL_HOME/data} if the {@code CRAFTY_BRAZIL_HOME}
	 * environment variable if it is set. If it is not set defaults to using
	 * {@code ./data} as the data directory.
	 * </p>
	 *
	 * @return The CRAFTY Brazil project's data directory.
	 * @throws FileNotFoundException If the {@code CRAFTY_BRAZIL_HOME} environment
	 *                               variable is set but the directory
	 *                               {@code $CRAFTY_BRAZIL_HOME/data} directory does
	 *                               not exist, or if the {@code CRAFTY_BRAZIL_HOME}
	 *                               directory is <emph>not</emph> set and the
	 *                               {@code ./data} directory does not exist.
	 */
	public static File getDataDir() throws FileNotFoundException {
		if (readCraftyBrazilHomeEnvVar() != null) {
			return getDataDirFromEnvironment();
		} else {
			logger.warn("CRAFTY_BRAZIL_HOME environment variable not set. Defaulting to current working directory.");
			return getDefaultDataDir();
		}
	}

	/**
	 * Get the path to the CRAFTY Brazil project data directory assuming the
	 * {@code CRAFTY_BRAZIL_HOME} environment variable is set.
	 *
	 *
	 * @return The path to {@code $CRAFTY_BRAZIL_HOME/data}.
	 * @throws FileNotFoundException If no directory exists at
	 *                               {@code $CRAFTY_BRAZIL_HOME/data}.
	 */
	public static File getDataDirFromEnvironment() throws FileNotFoundException {
		File craftyBrazilHomeDir = new File(readCraftyBrazilHomeEnvVar());
		File dataDir = new File(craftyBrazilHomeDir, "data");
		validateDataDir(dataDir);
		return dataDir;
	}

	private static String readCraftyBrazilHomeEnvVar() {
		return System.getenv("CRAFTY_BRAZIL_HOME");
	}

	/**
	 * Get the path to the CRAFTY Brazil project data directory assuming the current
	 * working directory is the CRAFTY Brazil project root.
	 *
	 * @return The path to {@code ./data}.
	 * @throws FileNotFoundException If no directory exists at {@code ./data}.
	 */
	public static File getDefaultDataDir() throws FileNotFoundException {
		File currentDir = new File(System.getProperty("user.dir"));
		File dataDir = new File(currentDir, "data");
		validateDataDir(dataDir);
		return dataDir;
	}

	private static void validateDataDir(File dir) throws FileNotFoundException {
		if (!dir.isDirectory()) {
			throw new FileNotFoundException(dir + " is not a valid data directory");
		}
	}

}
