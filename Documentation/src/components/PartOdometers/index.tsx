import React from "react";
import styles from "./styles.module.css";
import {
  allComponents,
  allComponentsById,
  allTypes,
} from "@site/src/lib/lineItemTypes";

export default function PartOdometers() {
  return (
    <ul>
      {allComponents.map((component) => (
        <li className={styles.listitem} key={component.id}>
          <p>{component.name}</p>
          {component.filter ? (
            <p>Filter: {allComponentsById[component.filter].name}</p>
          ) : null}
          <p>Line item types which reset this part odometer:</p>
          <ul>
            {allTypes
              .filter((type) => type.replaces === component.id)
              .map((type) => (
                <li key={type.id}>{type.displayName}</li>
              ))}
          </ul>
        </li>
      ))}
    </ul>
  );
}
