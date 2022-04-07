import React from "react";
import { categories, allComponentsById } from "@site/src/lib/lineItemTypes";
import { Category, Field, Type } from "@site/src/generated/LineItemTypes";
import styles from "./styles.module.css";
import { useState } from "react";
import { useEffect } from "react";

function enumValuesString(enumValues: { displayName: string }[]): string {
  const lf = new Intl.ListFormat("en", { type: "disjunction" });
  return lf.format(enumValues.map((enumValue) => `"${enumValue.displayName}"`));
}

function fieldTypeString(field: Field): string {
  switch (field.type) {
    case "boolean":
      return "Boolean";
    case "enum":
      return enumValuesString(field.enumValues ?? []);
    case "integer":
      return "Number";
    case "string":
      return "Text";
    case "tireSet":
      return "Tire set";
  }
}

function Anchor({ type, id }: { type: string; id: string }) {
  return (
    <a className={styles.anchor} id={`${type}_${id}`} href={`#${type}_${id}`}>
      #
    </a>
  );
}

function FieldItem({ field, type }: { field: Field; type: Type }) {
  return (
    <li className={styles.listitem}>
      <p>
        {field.shortDisplayName} ({fieldTypeString(field)})
        <Anchor type="field" id={`${type.id}_${field.id}`} />
      </p>
      <p>
        <small>Alternatively, "{field.longDisplayName}"</small>
      </p>
    </li>
  );
}

function TypeItem({ type }: { type: Type }) {
  const replaces = allComponentsById[type.replaces ?? ""];
  const replacesLine = replaces ? <p>Replaces: {replaces.name}</p> : "";
  const fields = type.fields ?? [];
  const fieldsList =
    fields.length > 0 ? (
      <>
        <p>Fields:</p>
        <ul>
          {fields.map((field) => (
            <FieldItem key={field.id} field={field} type={type} />
          ))}
        </ul>
      </>
    ) : (
      ""
    );

  return (
    <li className={styles.listitem}>
      <p>
        {type.displayName}
        <Anchor type="type" id={type.id} />
      </p>
      <p>
        Internal ID: <code>{type.id}</code>
      </p>
      {replacesLine}
      {fieldsList}
    </li>
  );
}

function CategoryItem({ category }: { category: Category }) {
  const [collapsed, setCollapsed] = useState(false);
  const [collapsible, setCollapsible] = useState(false);
  useEffect(() => {
    if (!collapsible) {
      setCollapsible(true);
      setCollapsed(true);
    }
  });

  const types = category.types ?? [];
  const subcategories = category.subcategories ?? [];

  const typeList =
    types.length > 0 ? (
      <>
        <p>Types:</p>
        <ul>
          {(category.types ?? []).map((type) => (
            <TypeItem key={type.id} type={type} />
          ))}
        </ul>
      </>
    ) : (
      ""
    );
  const subcategoryList =
    subcategories.length > 0 ? (
      <>
        <p>Subcategories:</p>
        <ul>
          {(category.subcategories ?? []).map((category) => (
            <CategoryItem key={category.id} category={category} />
          ))}
        </ul>
      </>
    ) : (
      ""
    );

  return (
    <li className={styles.listitem}>
      <p>
        {category.displayName}
        <Anchor type="category" id={category.id} />
      </p>
      <p>
        Internal ID: <code>{category.id}</code>
      </p>
      {collapsed ? (
        collapsible ? (
          <a href="#" onClick={() => setCollapsed(false)}>
            Expand
          </a>
        ) : (
          ""
        )
      ) : (
        <>
          {collapsible ? (
            <a href="#" onClick={() => setCollapsed(true)}>
              Collapse
            </a>
          ) : (
            ""
          )}
          {typeList}
          {subcategoryList}
        </>
      )}
    </li>
  );
}

export default function LineItemTypes() {
  return (
    <ul>
      {categories.map((category) => (
        <CategoryItem key={category.id} category={category} />
      ))}
    </ul>
  );
}
