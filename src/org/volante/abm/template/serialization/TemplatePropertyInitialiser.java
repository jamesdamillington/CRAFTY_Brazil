/**
 * 
 */
package org.volante.abm.template.serialization;


import org.volante.abm.agent.property.PropertyId;
import org.volante.abm.agent.property.PropertyRegistry;
import org.volante.abm.data.ModelData;
import org.volante.abm.data.Region;
import org.volante.abm.schedule.RunInfo;
import org.volante.abm.serialization.Initialisable;

/**
 * @author Sascha Holzhauer
 *
 */
public class TemplatePropertyInitialiser implements Initialisable {

	public enum AgentProperty implements PropertyId {
		PROPERTY1, PROPERTY2;
	}

	/**
	 * @see org.volante.abm.serialization.Initialisable#initialise(org.volante.abm.data.ModelData, org.volante.abm.schedule.RunInfo, org.volante.abm.data.Region)
	 */
	@Override
	public void initialise(ModelData data, RunInfo info, Region extent) throws Exception {
		PropertyRegistry.registerPropertiesEnum(TemplatePropertyInitialiser.AgentProperty.class);
	}

}
