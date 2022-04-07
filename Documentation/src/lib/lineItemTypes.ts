import {
  Category,
  LineItemTypesSchema,
  Type,
} from "@site/src/generated/LineItemTypes";
import lineItemTypesUntyped from "@site/src/generated/LineItemTypes.json";
const lineItemTypes = lineItemTypesUntyped as LineItemTypesSchema;

export const categories = lineItemTypes.categories;

function getAllSubcategories(category: Category): Category[] {
  const subcategories = category.subcategories ?? [];
  return subcategories.reduce(
    (acc, cat) => [...acc, ...getAllSubcategories(cat)],
    subcategories
  );
}

export const allCategories: Category[] = categories.reduce(
  (acc, cat) => [...acc, ...getAllSubcategories(cat)],
  categories
);

export const allCategoriesById = {};
for (const category of allCategories) {
  allCategoriesById[category.id] = category;
}

export const allTypes: Type[] = allCategories.reduce(
  (acc, cat) => [...acc, ...(cat.types ?? [])],
  [] as Type[]
);

export const allTypesById = {};
for (const type of allTypes) {
  allTypesById[type.id] = type;
}

export const allComponents = lineItemTypes.components ?? [];

export const allComponentsById = {};
for (const component of allComponents) {
  allComponentsById[component.id] = component;
}
