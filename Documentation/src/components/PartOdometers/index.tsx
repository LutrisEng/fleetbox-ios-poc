import React from "react";
import styles from "./styles.module.css";
import {
  Category,
  LineItemTypesSchema,
  Type,
} from "@site/src/generated/LineItemTypes";
import lineItemTypesUntyped from "@site/src/generated/LineItemTypes.json";
const lineItemTypes = lineItemTypesUntyped as LineItemTypesSchema;

function getCategoryTypes(category: Category): Type[] {
  return (category.subcategories ?? []).reduce(
    (acc, cat) => [...acc, ...getCategoryTypes(cat)],
    category.types ?? []
  );
}

const types = lineItemTypes.categories.reduce<Type[]>(
  (acc, cat) => [...acc, ...getCategoryTypes(cat)],
  []
);

const typesById = {};
for (const type of types) {
  typesById[type.id] = type;
}

const componentsById = {};
for (const component of lineItemTypes.components ?? []) {
  componentsById[component.id] = component;
}

export default function PartOdometers() {
  return (
    <ul>
      {(lineItemTypes.components ?? []).map((component) => (
        <li className={styles.listitem} key={component.id}>
          <p>{component.name}</p>
          {component.filter ? (
            <p>Filter: {componentsById[component.filter].name}</p>
          ) : null}
          <p>Line item types which reset this part odometer:</p>
          <ul>
            {types
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
