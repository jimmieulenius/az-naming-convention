type resolveItemType = {
  object: object?
  key: string
}

type placeholderInfoType = {
  name: string
  optional: bool
  type: string?
}?

type formatNameInfoType = {
  formatString: formatStringType
  separator: string?
  placeholders: placeholderInfoType[]
  values: object
  valueKeys: string[]
  validValueKeys: string[]
  casing: string?
  maxLength: int?
  additionalValues: bool
}

type formatNameResultType = {
  formatInfo: formatNameInfoType
  result: string
  isValid: bool
}

type placeholderLookupItemType = {
  value: string
  name: string
}

type instanceInfoType = {
  value: int?
  minValue: int?
  maxValue: int
  padding: {
    totalLength: int
    character: string
  }
}

type uniqueInfoType = {
  length: int?
  seed: string?
}

type formatStringType = {
  lookup: string
  value: string
}

type nameFunctionOptionType = 'formatName' | 'evaluateName'

@export()
func formatName(
  formatString string,
  values object,
  additionalValues bool?,
  config object
) string => evaluateName(
  formatString,
  values,
  additionalValues,
  true,
  config
).result

@export()
func evaluateName(
  formatString string,
  values object,
  additionalValues bool?,
  throwError bool?,
  config object
) formatNameResultType => sys.map(
  sys.map(
    sys.map(
      [
        {
          formatInfo: getFormatInfo(
            {
              lookup: formatString
              value: getFormatString(
                formatString,
                config
              )
            },
            values,
            additionalValues,
            throwError ?? false,
            config
          )
          result: null
          isValid: false
        }
      ],
      item => {
        formatInfo: item.formatInfo
        result: item.result
        isValid: validate(
          item.formatInfo,
          item.result,
          throwError ?? false
        )
      }
    ),
    item => {
      formatInfo: item.formatInfo
      result: item.isValid || !(throwError ?? false)
        ? sys.trim(
            replacePlaceholders(
              item.formatInfo
            )
          )
        : ''
      isValid: item.isValid
    }
  ),
  item => {
    formatInfo: item.formatInfo
    result: item.isValid
      ? applyCasing(
          item.result,
          item.formatInfo.casing
        )
      : item.result
    isValid: item.isValid
      ? validate(
          item.formatInfo,
          item.result,
          throwError ?? false
        )
      : false
  }
)[0]

@export()
func nameGraph(
  formatString string?,
  values object?,
  graph object,
  function nameFunctionOptionType,
  additionalValues bool?,
  config object
) object => applyOnGraph0(
  graph,
  function,
  {
    formatString: formatString == ''
      ? null
      : formatString
    values: values ?? {}
    additionalValues: additionalValues
    config: resolveConfig(config)
  }
)

func applyOnGraph0(
  object object,
  function nameFunctionOptionType,
  params object?
) object => sys.reduce(
  sys.map(
    sys.items(object),
    item => {
      key: item.key
      value: isObjectItem(item)
        ? isNameObject(item.value)
          ? invokeNameFunction(
              function,
              getNameFunctionParameters(
                item.value,
                params
              )
            ).result
          : applyOnGraph1(
              item,
              function,
              params
            )
        : item.value
    }
  ),
  {},
  (current, next) => sys.union(
    current,
    {
      '${next.key}': next.value
    }
  )
)

func applyOnGraph1(
  keyValue object,
  function nameFunctionOptionType,
  params object?
) object => sys.reduce(
  sys.map(
    sys.items(keyValue.value),
    item => {
      key: item.key
      value: isObjectItem(item)
        ? isNameObject(item.value)
          ? invokeNameFunction(
              function,
              getNameFunctionParameters(
                item.value,
                params
              )
            ).result
          : applyOnGraph2(
              item,
              function,
              params
            )
        : item.value
    }
  ),
  {},
  (current, next) => sys.union(
    current,
    {
      '${next.key}': next.value
    }
  )
)

func applyOnGraph2(
  keyValue object,
  function nameFunctionOptionType,
  params object?
) object => sys.reduce(
  sys.map(
    sys.items(keyValue.value),
    item => {
      key: item.key
      value: isObjectItem(item)
        ? isNameObject(item.value)
          ? invokeNameFunction(
              function,
              getNameFunctionParameters(
                item.value,
                params
              )
            ).result
          : applyOnGraph3(
              item,
              function,
              params
            )
        : item.value
    }
  ),
  {},
  (current, next) => sys.union(
    current,
    {
      '${next.key}': next.value
    }
  )
)

func applyOnGraph3(
  keyValue object,
  function nameFunctionOptionType,
  params object?
) object => sys.reduce(
  sys.map(
    sys.items(keyValue.value),
    item => {
      key: item.key
      value: isObjectItem(item)
        ? isNameObject(item.value)
          ? invokeNameFunction(
              function,
              getNameFunctionParameters(
                item.value,
                params
              )
            ).result
          : item.value
        : item.value
    }
  ),
  {},
  (current, next) => sys.union(
    current,
    {
      '${next.key}': next.value
    }
  )
)

func invokeNameFunction(
  function nameFunctionOptionType,
  params object
) object => {
  result: function == 'formatName'
    ? formatName(
        params.formatString,
        params.values,
        params.additionalValues,
        params.config
      )
    : evaluateName(
        params.formatString,
        params.values,
        params.additionalValues,
        null,
        params.config
      )
}

func getNameFunctionParameters(
  value object,
  params object?
) object => sys.union(
  params ?? {},
  {
    formatString: value.?formatString ?? params.?formatString ?? 'default'
    values: sys.union(
      params.?values ?? {},
      value.?values ?? {}
    )
  }
)

func isNameObject(object object?) bool => object.?formatString != null || object.?resourceType != null || object.?values != null

func isObjectItem(keyValue object) bool => sys.map(
  [
    {
      key: keyValue.key
      value: keyValue.value
      stringValue: sys.string(keyValue.value ?? '')
    }
  ],
  item => sys.startsWith(item.stringValue, '{') && sys.endsWith(item.stringValue, '}')
)[0]

func getFormatInfo(
  formatString formatStringType,
  values object,
  additionalValues bool?,
  throwError bool?,
  config object,
) formatNameInfoType => sys.map(
  [
    sys.map(
      [
        {
          formatString: formatString
          separator: getSeparatorString(
            getResourceTypeLookup(
              formatString.lookup,
              config
            ) ?? getResourceTypeLookup(
              values.?RESOURCE_TYPE ?? values.?RESOURCE,
              config
            ) ?? '',
            config
          )
          placeholders: getPlaceholderInfo(
            formatString.value,
            config
          )
          values: values
          valueKeys: sys.objectKeys(values)
          validValueKeys: []
          casing: getCasing(
            formatString.lookup,
            config
          )
          maxLength: getMaxLength(
            formatString.lookup,
            config
          )
          additionalValues: additionalValues ?? true
        }
      ],
      item => {
        formatString: item.formatString
        separator: item.separator
        placeholders: item.placeholders
        values: initializeValues(
          item,
          throwError,
          config
        )
        valueKeys: item.valueKeys
        validValueKeys: item.validValueKeys
        casing: item.casing
        maxLength: item.maxLength
        additionalValues: item.additionalValues
      }
    )[0]
  ],
  item => {
    formatString: item.formatString
    separator: item.separator
    placeholders: item.placeholders
    values: item.values
    valueKeys: item.valueKeys
    validValueKeys: getValidValueKeys(
      item.placeholders,
      item.values
    )
    casing: item.casing
    maxLength: item.maxLength
    additionalValues: item.additionalValues
  }
)[0]

func replacePlaceholders(
  formatInfo formatNameInfoType
) string => sys.join(
  sys.map(
    sys.map(
      sys.split(formatInfo.formatString.value, '['),
      item0 => sys.reduce(
        sys.map(
          sys.items(formatInfo.values),
          (item1) => {
            key: item1.key
            value: item1.value
            result: item0
          }
        ),
        {
          result: item0
        },
        (current, next) => {
          result: sys.contains(formatInfo.validValueKeys, next.key) && next.value != null
            ? sys.replace(current.result, '{${next.key}}', sys.string(next.value ?? ''))
            : current.result
        }
      ).result
    ),
    item => sys.contains(item, ']')
      ? sys.join(
          sys.map(
            sys.split(item, ']'),
            (item1, index1) => index1 > 0
              ? item1
              : sys.contains(item1, '{') && sys.contains(item1, '}')
                ? ''
                : item1
          ),
          ''
        )
      : item
  ),
  ''
)

func initializeValues(
  formatInfo formatNameInfoType,
  throwError bool?,
  config object
) object => sys.reduce(
  sys.map(
    sys.items(
      sys.union(
        (getResourceTypeLookup(
          formatInfo.formatString.lookup,
          config
        ) ?? getResourceTypeLookup(
          formatInfo.values.?RESOURCE_TYPE ?? formatInfo.values.?RESOURCE,
          config
        )) != null
          ? {
              RESOURCE: getResourceTypeLookup(
                formatInfo.formatString.lookup,
                config
              ) ?? getResourceTypeLookup(
                formatInfo.values.?RESOURCE_TYPE ?? formatInfo.values.?RESOURCE,
                config
              )
              RESOURCE_TYPE: getResourceTypeLookup(
                formatInfo.formatString.lookup,
                config
              ) ?? getResourceTypeLookup(
                formatInfo.values.?RESOURCE_TYPE ?? formatInfo.values.?RESOURCE,
                config
              )
            }
          : {},
        formatInfo.values,
        formatInfo.values[?'-'] == null && formatInfo.values.?SEPARATOR == null
          ? {
            '-': formatInfo.separator
            SEPARATOR: formatInfo.separator
          }
          : {}
      )
    ),
    (item0) => {
      '${item0.key}': sys.length(
        sys.filter(
          formatInfo.placeholders,
          item1 => item1.?name == item0.key
        )
      ) > 0
        ? item0.value != null && getPlaceholderType(
            item0.key,
            config
          ) == 'instance'
          ? getInstanceString(
              resolveInstanceValue(
                item0.value,
                item0.key,
                config
              )
            )
          : getPlaceholderType(
              item0.key,
              config
            ) == 'lookup'
            ? resolvePlaceholderLookupValue(
                item0.key,
                sys.string(item0.value ?? ''),
                throwError,
                config
              ).?value
            : getPlaceholderType(
                item0.key,
                config
              ) == 'unique'
              ? getUniqueString(
                  resolveUniqueValue(
                    item0.value,
                    formatInfo.values,
                    formatInfo.placeholders,
                    null,
                    config
                  )
                )
              : item0.value
        : null
    }
  ),
  {},
  (current, next) => sys.union(current, next)
)

func getResourceTypeLookup(
  value string?,
  config object
) string? => sys.contains(config.?placeholders.?RESOURCE_TYPE.?source ?? {}, sys.replace(value ?? '', ' ', ''))
  ? sys.replace(value ?? '', ' ', '')
  : null

func getPlaceholderType(
  name string,
  config object
) string? => config.?placeholders[?name][?'$type']

func resolvePlaceholderLookupValue(
  configKey string,
  valueKey string,
  throwError bool?,
  config object
) placeholderLookupItemType? => sys.map(
  [
    config.placeholders[configKey].source[?sys.replace(valueKey ?? '', ' ', '')] == null
      ? sys.replace(valueKey ?? '', ' ', '') == '' && config.placeholders[configKey].?default != null
        ? config.placeholders[configKey].source[sys.replace(config.placeholders[configKey].default ?? '', ' ', '')]
        : throwError ?? true
          ? config.placeholders[configKey].source[sys.replace(valueKey ?? '', ' ', '')]
          : null
      : config.placeholders[configKey].source[sys.replace(valueKey ?? '', ' ', '')]
  ],
  item => {
    value: item.?value ?? ''
    name: sys.replace(valueKey ?? '', ' ', '')
  }
)[0]

func resolveInstanceValue(
  value int?,
  configKey string?,
  config object
) instanceInfoType => {
  value: value
  minValue: resolveAny(
    [
      {
        key: 'minValue'
        object: config.?placeholders[?configKey ?? '']
      }
      {
        key: 'minValue'
        object: config.?placeholders.?INSTANCE
      }
    ]
  ).result
  maxValue: resolveAny(
    [
      {
        key: 'maxValue'
        object: config.?placeholders[?configKey ?? '']
      }
      {
        key: 'maxValue'
        object: config.?placeholders.?INSTANCE
      }
    ]
  ).result
  padding: {
    totalLength: resolveAny(
      [
        {
          key: 'totalLength'
          object: config.?placeholders[?configKey ?? ''].?padding
        }
        {
          key: 'totalLength'
          object: config.?placeholders.?INSTANCE.?padding
        }
      ]
    ).result
    character: resolveAny(
      [
        {
          key: 'character'
          object: config.?placeholders[?configKey ?? ''].?padding
        }
        {
          key: 'character'
          object: config.?placeholders.?INSTANCE.?padding
        }
      ]
    ).result
  }
}

func resolveUniqueValue(
  value object?,
  values object,
  placeholders placeholderInfoType[],
  configKey string?,
  config object
) uniqueInfoType => {
  length: resolveAny(
    [
      {
        key: 'length'
        object: value
      }
      {
        key: 'length'
        object: config.?placeholders[?configKey ?? '']
      }
      {
        key: 'length'
        object: config.?placeholders.?UNIQUE
      }
    ]
  ).result
  seed: resolveAny(
    [
      {
        key: 'seed'
        object: value
      }
      {
        key: 'seed'
        object: config.?placeholders[?configKey ?? '']
      }
      {
        key: 'seed'
        object: config.?placeholders.?UNIQUE
      }
    ]
  ).result ?? sys.reduce(
    sys.map(
      sys.items(values),
      (item) => {
        key: item.key
        value: item.value
        result: ''
      }
    ),
    {
      key: ''
      value: ''
      result: ''
    },
    (current, next) => {
      key: next.key
      value: next.value
      result: next.key != 'UNIQUE' && sys.length(
        sys.filter(
          placeholders,
          item => item.?name == next.key
        )
      ) > 0
        ? current.result == ''
          ? next.value
          : '${current.result},${next.value}'
        : current.result
    }
  ).result
}

func getRangedInt(
  value int?,
  minValue int?,
  maxValue int
) int => sys.range(
  minValue ?? 1,
  maxValue
)[(value ?? -1) - (minValue ?? 1) >= 0 ? (value ?? -1) - ((minValue ?? 1) - 1) : -1] -1

func getInstanceString(
  instanceInfo instanceInfoType
) string => sys.padLeft(
  getRangedInt(
    instanceInfo.value,
    instanceInfo.minValue,
    instanceInfo.maxValue
  ),
  instanceInfo.padding.totalLength,
  instanceInfo.padding.character
)

func getUniqueString(
  uniqueInfo uniqueInfoType
) string => sys.substring(
  sys.uniqueString(uniqueInfo.seed ?? ''),
  0,
  uniqueInfo.length ?? -1
)

func getFormatString(
  configKey string,
  config object
) string => sys.contains(configKey, '{') && sys.contains(configKey, '}')
  ? configKey
  : resolveFormatValue(
    configKey,
    'formatString',
    config
  ) ?? configKey

func getSeparatorString(
  configKey string,
  config object
) string? => resolveFormatValue(
  configKey,
  'separator',
  config
) ?? ''

func getCasing(
  configKey string,
  config object
) string? => resolveFormatValue(
  configKey,
  'casing',
  config
)

func getMaxLength(
  configKey string,
  config object
) int? => sys.json('{"value":${resolveFormatValue(configKey, 'maxLength', config) ?? 'null'}}').value

func applyCasing(value string, casing string?) string => sys.toLower(casing ?? '') == 'lower'
  ? sys.toLower(value)
  : sys.toLower(casing ?? '') == 'upper'
    ? sys.toUpper(value)
    : value

func getPlaceholderInfo(
  formatString string,
  config object
) placeholderInfoType[] => sys.concat(
  sys.filter(
    sys.reduce(
      sys.map(
        sys.split(formatString, '['),
        item1 => sys.contains(item1, ']')
          ? sys.reduce(
            sys.map(
              sys.split(item1, ']'),
              (item2, index2) => sys.map(
                sys.filter(
                  sys.split(item2, '{'),
                  item3 => (item3 ?? '') != ''
                ),
                item4 => toPlaceholderInfo(
                  sys.split(item4, '}')[0] ?? '',
                  index2 == 0,
                  config
                )
              )
            ),
            [],
            (current2, next2) => sys.concat(current2, next2)
          )
          : sys.map(
            sys.filter(
              sys.split(item1, '{'),
              item5 => (item5 ?? '') != ''
            ),
            item6 => toPlaceholderInfo(
              sys.split(item6, '}')[0] ?? '',
              false,
              config
            )
          )
      ),
      [],
      (current1, next1) => sys.concat(current1, next1)
    ),
    item => item != null
  ),
  [
    {
      name: '-'
      optional: false
      type: 'constant'
    }
    {
      name: 'SEPARATOR'
      optional: false
      type: 'constant'
    }
  ]
)

func toPlaceholderInfo(
  name string,
  optional bool,
  config object
) placeholderInfoType? => !sys.contains(
  [
    ''
    '-'
    'SEPARATOR'
  ],
  sys.trim(name)
)
  ? {
      name: sys.trim(name)
      optional: optional
      type: config.?placeholders[?name][?'$type']
    }
  : null

func validate(
  formatInfo formatNameInfoType,
  result string?,
  throwError bool?
) bool => (validatePlaceholders(
  formatInfo.placeholders,
  formatInfo.valueKeys,
  formatInfo.validValueKeys,
  throwError
) && validateValues(
  formatInfo.placeholders,
  formatInfo.valueKeys,
  formatInfo.additionalValues,
  throwError
) && (sys.length(formatInfo.validValueKeys) > 0) && (result != null
  ? validateLength(formatInfo, result ?? '', throwError)
  : true))

func validateValues(
  placeholders placeholderInfoType[],
  valueKeys string[],
  additionalValues bool,
  throwError bool?
) bool => additionalValues
  ? true
  : sys.map(
    [
      sys.reduce(
        sys.map(
          valueKeys,
          item1 => {
            item: item1
            isValid: sys.length(
              sys.filter(
                placeholders,
                item2 => item2.?name == item1
              )
            ) > 0
            error: []
          }
        ),
        {
          item: null
          isValid: null
          error: []
        },
        (current, next) => {
          error: sys.concat(
            current.error,
            !(next.isValid ?? true)
              ? [
                  next.item
                ]
              : []
          )
        }
      )
    ],
    item0 => sys.length(item0.error) == 0
      ? null
      : throwError ?? true
        ? sys.reduce(
          sys.map(
            placeholders,
            item => {
              '${item.?name ?? ''}': null
            }
          ),
          {},
          (current, next) => sys.union(
            current,
            next
          )
        )['placeholder: \'${sys.join(item0.error, ', ')}\'']
        : item0.error
  )[0] == null

func validatePlaceholders(
  placeholders placeholderInfoType[],
  valueKeys string[],
  validValueKeys string[],
  throwError bool?
) bool => sys.map(
  [
    sys.reduce(
      sys.map(
        placeholders,
        item => {
          item: item
          isValid: (item.?optional ?? true)
            ? true
            : sys.contains(validValueKeys, item.?name ?? '')
          error: []
        }
      ),
      {
        item: null
        isValid: null
        error: []
      },
      (current, next) => {
        error: sys.concat(
          current.error,
          !(next.isValid ?? true)
            ? [
                next.item.?name ?? ''
              ]
            : []
        )
      }
    )
  ],
  item0 => sys.length(item0.error) == 0
    ? null
    : throwError ?? true
      ? sys.reduce(
        sys.map(
          valueKeys,
          item1 => {
            '${item1}': null
          }
        ),
        {},
        (current, next) => sys.union(
          current,
          next
        )
      )['value: \'${sys.join(item0.error, ', ')}\'']
      : item0.error
)[0] == null

func validateLength(
  formatInfo formatNameInfoType,
  result string,
  throwError bool?
) bool => result != ''
  ? formatInfo.maxLength != null
    ? throwError ?? true
      ? sys.range(
          0,
          formatInfo.maxLength ?? 0
        )[sys.length(result) - 1] > 0
      : sys.length(result) <= (formatInfo.maxLength ?? 0)
    : true
  : sys.string(emptyArray()[0]) != ''

func emptyArray() array => []

func getValidValueKeys(
  placeholders placeholderInfoType[],
  values object
) string[] => sys.union(
  sys.filter(
    sys.map(
      placeholders,
      item => sys.trim(sys.string(values[?item.?name ?? ''] ?? '')) != ''
      ? item.?name ?? ''
      : item.?optional ?? false
        ? sys.contains(values, item.?name ?? '')
          ? item.?name ?? ''
          : ''
        : ''
    ),
    item => item != ''
  ),
  [
    '-'
    'SEPARATOR'
  ]
)

func resolveFormatValue(
  configKey string,
  valueKey string,
  config object
) string? => sys.map(
  [
    resolveAny(
      [
        {
          key: '$value'
          object: sys.contains(sys.string(config.?format[?configKey][?valueKey] ?? {}), '"$value":')
            ? config.?format[?configKey][?valueKey]
            : {}
        }
      ]
    )
  ],
  item => item.hasValue
    ? item
    : resolveAny(
      [
        {
          key: valueKey
          object: config.?format[?configKey]
        }
        {
          key: valueKey
          object: config.?format.?default
        }
      ]
    )
)[0].stringResult

func resolveAny(
  items resolveItemType[]
) object => sys.reduce(
  sys.map(
    items,
    item => {
      key: item.key
      object: item.object
      result: null
      stringResult: null
      hasValue: false
    }
  ),
  {
    result: null
    stringResult: null
    hasValue: false
  },
  (current, next) => {
    result: !current.hasValue
      ? next.object[?next.key]
      : current.result
    stringResult: !current.hasValue
      ? sys.trim(sys.string(next.object[?next.key] ?? '')) != ''
        ? sys.string(next.object[?next.key] ?? '')
        : current.stringResult
      : current.stringResult
    hasValue: current.hasValue
      ? true
      : next.object[?next.key] != null || (sys.contains(
          next.object ?? {},
          next.key
        ) && next.key == '$value')
  }
)

@export()
func resolveRef(
  ref object,
  object object
) object => {
  result: sys.reduce(
    sys.map(
      sys.skip(
        sys.split(ref.path, '/'),
        1
      ),
      item => {
        key: item
        object: null
      }
    ),
    {
      object: object
    },
    (current, next) => {
      object: current.object[?next.key]
    }
  ).object
}

@export()
func resolveConfig(config object) object => resolveRefObject0(
  config,
  config
)

func resolveRefObject0(
  root object,
  object object
) object => sys.reduce(
  sys.map(
    sys.items(object),
    item => {
      key: item.key
      value: item.value
      result: {}
    }
  ),
  {
    result: {}
  },
  (current, next) => {
    result: sys.union(
      current.result,
      sys.startsWith(next.key, '$ref:')
        ? {
            '${sys.substring(next.key, 5)}': resolveRef(next.value, root).result
          }
        : sys.startsWith(sys.string(next.value ?? ''), '{') && sys.endsWith(sys.string(next.value ?? ''), '}')
          ? {
              '${next.key}': resolveRefObject1(
                root,
                next.value
              )
            }
          : {
              '${next.key}': next.value
            }
    )
  }
).result

func resolveRefObject1(
  root object,
  object object
) object => sys.reduce(
  sys.map(
    sys.items(object),
    item => {
      key: item.key
      value: item.value
      result: {}
    }
  ),
  {
    result: {}
  },
  (current, next) => {
    result: sys.union(
      current.result,
      sys.startsWith(next.key, '$ref:')
        ? {
            '${sys.substring(next.key, 5)}': resolveRef(next.value, root).result
          }
          : sys.startsWith(sys.string(next.value ?? ''), '{') && sys.endsWith(sys.string(next.value ?? ''), '}')
          ? {
              '${next.key}': resolveRefObject2(
                root,
                next.value
              )
            }
          : {
              '${next.key}': next.value
            }
    )
  }
).result

func resolveRefObject2(
  root object,
  object object
) object => sys.reduce(
  sys.map(
    sys.items(object),
    item => {
      key: item.key
      value: item.value
      result: {}
    }
  ),
  {
    result: {}
  },
  (current, next) => {
    result: sys.union(
      current.result,
      sys.startsWith(next.key, '$ref:')
        ? {
            '${sys.substring(next.key, 5)}': resolveRef(next.value, root).result
          }
          : sys.startsWith(sys.string(next.value ?? ''), '{') && sys.endsWith(sys.string(next.value ?? ''), '}')
          ? {
              '${next.key}': resolveRefObject3(
                root,
                next.value
              )
            }
          : {
              '${next.key}': next.value
            }
    )
  }
).result

func resolveRefObject3(
  root object,
  object object
) object => sys.reduce(
  sys.map(
    sys.items(object),
    item => {
      key: item.key
      value: item.value
      result: {}
    }
  ),
  {
    result: {}
  },
  (current, next) => {
    result: sys.union(
      current.result,
      sys.startsWith(next.key, '$ref:')
        ? {
            '${sys.substring(next.key, 5)}': resolveRef(next.value, root).result
          }
        : {
            '${next.key}': next.value
          }
    )
  }
).result
