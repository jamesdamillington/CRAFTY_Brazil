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


import org.volante.abm.data.ModelData;
import org.volante.abm.data.Region;
import org.volante.abm.output.Outputter;
import org.volante.abm.schedule.RunInfo;


/**
 * Initialisation is there to allow objects to set themselves up. In particular to load serialised
 * data.
 * 
 * The Region parameter extent is to allow regional initialisation where appropriate.For classes
 * like {@link Outputter} that are not initialised per region but globally there is an alternative
 * Interface {@link GloballyInitialisable}.
 * 
 * @author dmrust
 * 
 */
public interface Initialisable {

	/**
	 * @param data
	 *        model data
	 * @param info
	 *        run information
	 * @param extent
	 *        region the initialisable object belongs to
	 * @throws Exception
	 */
	public void initialise(ModelData data, RunInfo info, Region extent) throws Exception;
}